package main

import (
	"os"
	"path/filepath"
	"testing"

	lua "github.com/yuin/gopher-lua"
)

func TestMelixisDialogueAndExchanges(t *testing.T) {
	scriptPath := os.Getenv("MELIXIS_SCRIPT")
	if scriptPath == "" {
		scriptPath = "../changes/kerraridge-melixis-dialogue/Melixis.lua"
	}
	script, err := os.ReadFile(scriptPath)
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
	if err := state.DoString(string(script)); err != nil {
		t.Fatal(err)
	}
	if err := state.DoString(`
local responses = {}
local function run_say(message)
 local npc = { Say = function(_, text) table.insert(responses, text) end }
 event_say({self = npc, message = message})
end
run_say("Hail Melixis")
run_say("what shiny tings")
run_say("what dull ring")
run_say("what kinda shiny ring")
run_say("what really shiny ring")
local expected = {
 "Welcome to Melixis shop.Rrrr. Feel free to brrrowse through my wares.  Melixis also find some [shiny tings] that she may trade you.",
 "In Melixis travels of the Odus, she find a [dull ring], a [kinda shiny ring] and a [really shiny ring]. Maybe you want to trade for those tings. Rrrr.",
 "For dat ting? You brrring Melixis some bracket mildew. Rarr.",
 "Hmm Hamed need faerix spores forrr potion. Rrrrr. You bring some to Melixis and she gives you the kinda shiny ring.",
 "You go find degenerated guk weed. Melixis gives you the really shiny ring."
}
for i, text in ipairs(expected) do assert(responses[i] == text, "P99 dialogue mismatch at response " .. i) end
local expected_handins = {
 {14042, 13733, "Many thanks.. rrrr.. here is dull ring."},
 {14043, 13731, "Melixis thanks you, Hamed will be pleased. A kinda shiny ring is yours."},
 {14044, 13732, "You done good job, furless one. Here is really shiny ring. Rarr.."}
}
for _, expected in ipairs(expected_handins) do
 local result = {items = {}, returned = {}, responses = {}}
 local npc = {}
 local trade
 local player = {SummonItem = function(_, id) table.insert(result.items, id) end}
 function npc:Say(text) table.insert(result.responses, text) end
 function npc:CheckHandin(_, offered, required)
  for id, amount in pairs(required) do if (offered[id] or 0) < amount then return false end end
  result.consumed = required
  return true
 end
 function npc:ReturnHandinItems()
  for i = 1, 4 do
   local item = trade["item" .. i]
   if item.valid and (not result.consumed or not result.consumed[item:GetID()]) then
    table.insert(result.returned, item:GetID())
   end
  end
 end
 local ids = {expected[1], 99999}
 trade = {self = npc, other = player}
 for i = 1, 4 do
  local id = ids[i] or 0
  trade["item" .. i] = {valid = id ~= 0, GetID = function() return id end}
 end
 event_trade({self = npc, other = player, trade = trade})
 assert(#result.items == 1 and result.items[1] == expected[2], "wrong ring reward for item " .. expected[1])
 assert(#result.responses == 1 and result.responses[1] == expected[3], "wrong hand-in response for item " .. expected[1])
 assert(#result.returned == 1 and result.returned[1] == 99999, "unrelated offer was not returned")
end
local rejected = {items = {}, returned = {}}
local npc = {}
local trade
local player = {SummonItem = function(_, id) table.insert(rejected.items, id) end}
function npc:Say(_) end
function npc:CheckHandin() return false end
function npc:ReturnHandinItems()
 if trade.item1.valid then table.insert(rejected.returned, trade.item1:GetID()) end
end
trade = {self = npc, other = player}
local wrong_id = 99998
trade.item1 = {valid = true, GetID = function() return wrong_id end}
for i = 2, 4 do trade["item" .. i] = {valid = false, GetID = function() return 0 end} end
event_trade({self = npc, other = player, trade = trade})
assert(#rejected.items == 0 and #rejected.returned == 1 and rejected.returned[1] == wrong_id, "rejected offer must return without reward")
`); err != nil {
		t.Fatal(err)
	}
}
