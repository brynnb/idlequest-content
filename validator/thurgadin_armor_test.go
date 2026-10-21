package main

import (
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	lua "github.com/yuin/gopher-lua"
)

func TestThurgadinArmor(t *testing.T) {
	var sets []struct {
		NPC     string `json:"npc"`
		Class   string `json:"class"`
		Recipes []struct{ Armor, Gem, Count, Reward int }
	}
	fixture, err := os.ReadFile("../changes/thurgadin-armor-responses/recipes.json")
	if err != nil {
		t.Fatal(err)
	}
	if err := json.Unmarshal(fixture, &sets); err != nil {
		t.Fatal(err)
	}
	if len(sets) != 14 {
		t.Fatalf("want 14 sets, got %d", len(sets))
	}
	dir := os.Getenv("THURGADIN_SCRIPT_DIR")
	if dir == "" {
		dir = "../changes/thurgadin-armor-responses"
	}
	items, err := os.ReadFile("../effective/modules/items.lua")
	if err != nil {
		t.Fatal(err)
	}
	for _, set := range sets {
		t.Run(set.NPC, func(t *testing.T) {
			if len(set.Recipes) != 7 {
				t.Fatal("want seven slots")
			}
			l := lua.NewState()
			defer l.Close()
			if err := l.DoString(`function string.findi(s,p) return string.find(string.lower(s),string.lower(p),1,true) end`); err != nil {
				t.Fatal(err)
			}
			l.PreloadModule("items", func(l *lua.LState) int {
				if err := l.DoString(string(items)); err != nil {
					l.RaiseError("%v", err)
				}
				return 1
			})
			if err := l.DoFile(filepath.Join(dir, set.NPC+".lua")); err != nil {
				t.Fatal(err)
			}
			if err := l.DoString(`
function run(ids, message)
 local r = {rewards={}, factions={}, speech={}, emotes={}, exp=0, returned={}}
 local offered, consumed = {}, {}
 local npc, player = {}, {}
 function npc:Say(s) table.insert(r.speech,s) end
 function npc:Emote(s) table.insert(r.emotes,s) end
 function player:GetCleanName() return "Testplayer" end
 function player:GetRaceName() return "Human" end
 function player:SummonItem(id) table.insert(r.rewards,id) end
 function player:AddEXP(n) r.exp=r.exp+n end
 function player:Faction(id,n) r.factions[id]=(r.factions[id] or 0)+n end
 function npc:CheckHandin(client, actual, required)
  for id,n in pairs(required) do
   if (actual[id] or 0)-(consumed[id] or 0)<n then return false end
  end
  for id,n in pairs(required) do consumed[id]=(consumed[id] or 0)+n end
  return true
 end
 function npc:ReturnHandinItems(client)
  for id,n in pairs(offered) do
   if n>(consumed[id] or 0) then r.returned[id]=n-(consumed[id] or 0) end
  end
 end
 if message then
  event_say({self=npc,other=player,message=message})
 else
  local trade={self=npc,other=player,gold=5}
  offered.gold=5
  for i=1,4 do
   local id=ids[i] or 0
   if id~=0 then offered[id]=(offered[id] or 0)+1 end
   trade['item'..i]={valid=id~=0,GetID=function() return id end}
  end
  event_trade({self=npc,other=player,trade=trade})
 end
 return r
end
function check(armor,gem,count,reward,named)
 assert(count==3,'fixture must require three gems')
 for attempt=1,2 do
  local r=run({armor,gem,gem,gem})
  assert(#r.rewards==1 and r.rewards[1]==reward,'wrong armor reward')
  assert(r.exp==100000,'existing approximate EXP changed')
  assert(r.factions[406]==20 and r.factions[405]==20 and r.factions[419]==-60 and r.factions[448]==-60,'existing faction effects changed')
  assert(#r.emotes==1 and r.emotes[1]=='smiles warmly as he hands you your reward.','P99 completion emote missing')
  local expected=named and 'You have done well, Testplayer.' or 'You have done well.'
  assert(#r.speech==1 and r.speech[1]==expected,'wrong P99 completion response')
  assert(r.returned.gold==5,'surplus coin must return')
  for id in pairs(r.returned) do assert(id=='gold','required items must be consumed') end
 end
 for _,offer in ipairs({{armor,gem,gem},{armor,gem,gem,13014},{gem,gem,gem},{armor},{13014}}) do
  local r=run(offer)
  assert(#r.rewards==0 and #r.emotes==0 and #r.speech==0 and r.exp==0 and next(r.factions)==nil,'invalid offer rewarded')
  local expected={gold=5}
  for _,id in ipairs(offer) do expected[id]=(expected[id] or 0)+1 end
  for id,n in pairs(expected) do assert(r.returned[id]==n,'unmatched items and coins must return') end
 end
end
`); err != nil {
				t.Fatal(err)
			}
			for _, recipe := range set.Recipes {
				err := l.CallByParam(lua.P{Fn: l.GetGlobal("check"), NRet: 0, Protect: true}, lua.LNumber(recipe.Armor), lua.LNumber(recipe.Gem), lua.LNumber(recipe.Count), lua.LNumber(recipe.Reward), lua.LBool(set.Class != "cleric"))
				if err != nil {
					t.Fatalf("reward %d: %v", recipe.Reward, err)
				}
			}
			phrases := map[string]map[string]string{
				"cleric":  {"helm": "corroded plate helmet", "greaves": "corroded plate greaves"},
				"warrior": {"greaves": "corroded plate greaves"},
				"wizard":  {"I am a wizard": "tasks for you to accomplish"},
			}
			for message, phrase := range phrases[set.Class] {
				l.SetGlobal("test_message", lua.LString(message))
				l.SetGlobal("test_phrase", lua.LString(phrase))
				if err := l.DoString(`local r=run({},test_message); assert(#r.speech==1 and string.find(r.speech[1],test_phrase,1,true),'documented armor dialogue missing')`); err != nil {
					t.Fatal(err)
				}
			}
			if set.Class == "enchanter" {
				if err := l.DoString(`
local r=run({1427,1417,13014})
assert(#r.rewards==1 and r.rewards[1]==1424 and r.exp==150000,'shawl kitchen hand-in changed')
assert(r.returned[13014]==1 and r.returned.gold==5,'shawl surplus must return')
assert(#r.emotes==0,'shawl hand-in must not use armor emote')
r=run({1427,13014})
assert(#r.rewards==0 and r.exp==5000 and next(r.factions)==nil,'pie-only alternative changed')
assert(r.returned[13014]==1,'pie-only surplus must return')
r=run({},'hail')
assert(r.speech[1]=='Greetings to you.  I see those who call themselves enchanters.  Are you an enchanter?','P99 Brita hail')
`); err != nil {
					t.Fatal(err)
				}
			}
		})
	}
}
