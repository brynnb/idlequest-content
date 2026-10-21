package main

import (
	lua "github.com/yuin/gopher-lua"
	"os"
	"path/filepath"
	"testing"
)

func TestGrettaMuffins(t *testing.T) {
	script := os.Getenv("GRETTA_SCRIPT")
	if script == "" {
		script = "../changes/kaladima-gretta-muffins/Gretta_Mottle.lua"
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
local function context(ids)
 local r = {items = {}, messages = {}, factions = {}, returned = {}, exp = 0, gold = 0}
 local npc, player = {}, {}
 function npc:Say(text) table.insert(r.messages, text) end
 function npc:Emote(text) table.insert(r.messages, text) end
 function player:GetName() return 'Baker' end
 function player:SummonItem(id) table.insert(r.items, id) end
 function player:AddEXP(amount) r.exp = r.exp + amount end
 function player:Ding() r.ding = true end
 function player:Faction(id, amount) r.factions[id] = (r.factions[id] or 0) + amount end
 function player:GiveCash(copper, silver, gold, platinum)
  assert(copper == 0 and silver == 0 and platinum == 0, 'unexpected currency')
  r.gold = r.gold + gold
 end
 function npc:CheckHandin(client, offered, required, instances)
  for id, count in pairs(required) do if (offered[id] or 0) < count then return false end end
  r.consumed = required
  return true
 end
 function npc:ReturnHandinItems(client)
  for _, id in ipairs(ids or {}) do
   if not r.consumed or not r.consumed[id] then table.insert(r.returned, id) end
  end
 end
 local trade = {self = npc, other = player}
 for i = 1, 4 do
  local id = ids and ids[i] or 0
  trade['item' .. i] = {valid = id ~= 0, GetID = function() return id end}
 end
 return r, {self = npc, other = player, trade = trade}
end
for _, phrase in ipairs({'help to bake', 'I will help to bake', 'WHAT HELP TO BAKE'}) do
 local r, e = context()
 e.message = phrase
 event_say(e)
 assert(#r.messages == 1 and r.messages[1]:find('[bake muffins]', 1, true), 'P99 help phrase must offer muffin task')
end
for _, phrase in ipairs({'bake muffins', 'I will help bake muffins', 'WHAT BAKE MUFFINS'}) do
 local r, e = context()
 e.message = phrase
 event_say(e)
 assert(#r.items == 1 and r.items[1] == 17881, 'muffin task must give Muffin Crate')
 assert(r.messages[1]:find('seal them in', 1, true), 'crate instructions must explain sealing')
end
local r, e = context()
e.message = 'fetch some bread'
event_say(e)
assert(r.messages[1]:find('Jarlen Meadowgreen', 1, true), 'bread directions must remain reachable')
assert(type(event_trade) == 'function', 'Full Muffin Crate needs a hand-in handler')
for attempt = 1, 2 do
 local r, e = context({1839, 13014})
 event_trade(e)
 assert(r.consumed[1839] == 1, 'must accept Full Muffin Crate')
 assert(r.exp == 500 and r.ding, 'must grant experience')
 assert(r.gold >= 5 and r.gold <= 8, 'fallback reward is 5-8 gold')
 assert(r.factions[290] == 2 and r.factions[312] == 1 and r.factions[322] == -1 and r.factions[293] == 1 and r.factions[274] == 1, 'must grant five faction changes')
 assert(#r.returned == 1 and r.returned[1] == 13014, 'unrelated muffin must be returned')
 assert(r.messages[1]:find('You truly are a fine baker', 1, true), 'must acknowledge completed crate')
end
for _, ids in ipairs({{}, {17881}, {13014}, {1838}}) do
 local r, e = context(ids)
 event_trade(e)
 assert(not r.consumed and r.exp == 0 and r.gold == 0 and next(r.factions) == nil, 'wrong offer must not reward')
 assert(#r.returned == #ids, 'wrong offer must return every offered item')
end
`); err != nil {
		t.Fatal(err)
	}
}
