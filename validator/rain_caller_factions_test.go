package main

import (
	"os"
	"path/filepath"
	"testing"

	lua "github.com/yuin/gopher-lua"
)

func TestRainCallerFactionRewards(t *testing.T) {
	script := os.Getenv("KINOOL_SCRIPT")
	if script == "" {
		script = "../changes/felwitheb-rain-caller-factions/Kinool_Goldsinger.lua"
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
 local result = { items = {}, factions = {}, returned = {}, exp = 0, ding = 0 }
 local npc = {}
 local player = {}
 function npc:Say(text) end
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
 local r = run({12333, 12334, 8401, 13014}, 3000)
 assert(#r.items == 1 and r.items[1] == 8402, 'final hand-in must award Rain Caller once')
 assert(r.exp == 5000 and r.ding == 1, 'existing experience and ding must remain')
 assert(r.factions[275] == 25, 'missing Keepers of the Art reward')
 assert(r.factions[279] == 6, 'missing King Tearis Thex reward')
 assert(r.factions[246] == 3, 'missing Faydarks Champions reward')
 assert(r.factions[239] == -6, 'missing The Dead penalty')
 assert(#r.returned == 1 and r.returned[1] == 13014, 'unrelated item must be returned')
end
for _, offer in ipairs({
 {items = {12333, 12334, 8401}, gold = 2999},
 {items = {12333, 12334}, gold = 3000},
 {items = {13014}, gold = 3000}
}) do
 local r = run(offer.items, offer.gold)
 assert(#r.items == 0 and next(r.factions) == nil and r.exp == 0, 'incomplete offer must not reward')
 assert(#r.returned == #offer.items, 'incomplete offer must return items')
end
local r = run({18778}, 0)
assert(#r.items == 1 and r.items[1] == 13593, 'enrollment robe must remain')
assert(r.exp == 100 and r.ding == 1, 'enrollment experience must remain')
assert(r.factions[275] == 100 and r.factions[279] == 25 and r.factions[246] == 15 and r.factions[239] == -25, 'enrollment faction must remain')
`); err != nil {
		t.Fatal(err)
	}
}
