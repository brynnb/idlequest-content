package main

import (
	"os"
	"path/filepath"
	"testing"

	lua "github.com/yuin/gopher-lua"
)

func TestReivajFactionRewards(t *testing.T) {
	script := os.Getenv("REIVAJ_SCRIPT")
	if script == "" {
		script = "../changes/kael-reivaj-factions/Reivaj_the_Battlerager.lua"
	}
	source, err := os.ReadFile(script)
	if err != nil {
		t.Fatal(err)
	}
	items, err := os.ReadFile(filepath.Join("..", "effective", "modules", "items.lua"))
	if err != nil {
		t.Fatal(err)
	}
	state := lua.NewState()
	defer state.Close()
	if err := state.DoString(`function string.findi(s, pattern) return string.find(string.lower(s), string.lower(pattern), 1, true) end`); err != nil {
		t.Fatal(err)
	}
	state.PreloadModule("items", func(l *lua.LState) int {
		if err := l.DoString(string(items)); err != nil {
			l.RaiseError("%v", err)
		}
		return 1
	})
	if err := state.DoString(string(source)); err != nil {
		t.Fatal(err)
	}
	if err := state.DoString(`
local function run(ids, gold)
 local result = { items = {}, factions = {}, returned = {}, exp = 0, ding = 0, speech = {} }
 local npc = {}
 local player = {}
 function npc:Say(text) table.insert(result.speech, text) end
 function npc:CheckHandin(client, offered, required, instances)
  for id, amount in pairs(required) do
   if (offered[id] or 0) < amount then return false end
  end
  result.consumed = required
  return true
 end
 function npc:ReturnHandinItems(client)
  for _, id in ipairs(ids) do
   if not result.consumed or not result.consumed[id] then
    table.insert(result.returned, id)
   end
  end
 end
 function player:SummonItem(id) table.insert(result.items, id) end
 function player:AddEXP(amount) result.exp = result.exp + amount end
 function player:Ding() result.ding = result.ding + 1 end
 function player:Faction(id, amount, temp)
  result.factions[id] = (result.factions[id] or 0) + amount
 end
 local trade = { self = npc, other = player, gold = gold or 0 }
 for i = 1, 4 do
  local id = ids[i] or 0
  trade['item' .. i] = {valid = id ~= 0, GetID = function() return id end}
 end
 event_trade({self = npc, other = player, trade = trade})
 return result
end
for attempt = 1, 2 do
 local r = run({25117, 13014}, 0)
 assert(#r.items == 1 and r.items[1] == 25083, 'fang must award exactly one Vehement Sword')
 assert(r.exp == 1000, 'existing experience must remain')
 assert(r.factions[419] == 25, 'missing Kromrif gain')
 assert(r.factions[448] == 6, 'missing Kromzek gain')
 assert(r.factions[406] == -12, 'missing Coldain loss')
 assert(r.factions[430] == -2, 'missing Claws of Veeshan loss')
 assert(#r.speech == 0, 'P99 hand-in has no reward speech')
 assert(#r.returned == 1 and r.returned[1] == 13014, 'unrelated item must be returned')
end
for _, ids in ipairs({{}, {13014}, {25083}}) do
 local r = run(ids, 0)
 assert(#r.items == 0 and next(r.factions) == nil and r.exp == 0, 'unmatched offer must not reward')
 assert(#r.returned == #ids, 'unmatched offer must return all items')
end
`); err != nil {
		t.Fatal(err)
	}
}
