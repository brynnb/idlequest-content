package quest

import (
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/require"
	lua "github.com/yuin/gopher-lua"
)

func TestScriptStateKeysRetainLegacyReadsAndDistinctTypes(t *testing.T) {
	for _, key := range []lua.LValue{
		lua.LNumber(0), lua.LNumber(-2), lua.LNumber(1.5), lua.LNumber(9007199254740991),
		lua.LString("#2"), lua.LString("#1.5"), lua.LString(""),
		lua.LString(scriptStateStringKey + "value"), lua.LString(scriptStateNumberKey + "2"),
	} {
		encoded, ok := encodeScriptStateKey(key)
		require.True(t, ok)
		require.Equal(t, key, decodeScriptStateKey(encoded))
	}
	L := lua.NewState()
	defer L.Close()
	legacy := luaEventValue(L, map[string]any{"#2": "number", "#1.5": "string"}).(*lua.LTable)
	require.Equal(t, lua.LString("number"), legacy.RawGetInt(2))
	require.Equal(t, lua.LString("string"), legacy.RawGetString("#1.5"))
	require.Equal(t, lua.LNil, legacy.RawGet(lua.LNumber(1.5)))
}

func TestMalformedTableAliasesCannotAwardQuestRewards(t *testing.T) {
	for _, aliases := range []any{"invalid", []luaTableAlias{{Destination: []string{"upvalue:counts"}, Source: []string{"upvalue:missing"}}}} {
		event := &LuaEvent{NPC: &NPCProxy{Name: "State"}, Player: &PlayerProxy{}, ScriptState: map[string]any{tableAliasStateKey: aliases}}
		capture, err := NewLuaBridge(".").ExecuteEventFromSource(`local counts={value=0}
function event_signal(e) counts.value=1; e.other:SummonItem(14366) end`, "event_signal", event)
		require.Error(t, err)
		require.Nil(t, capture)
	}
}

func TestLuaHelperStateAcrossFreshEvents(t *testing.T) {
	for _, tc := range []struct{ name, source, want string }{
		{"separate_equal_tables", `local counts={value=0}
local alias=counts
local stage=0
function event_signal(e)
 if stage==0 then alias={value=0} end
 assert(counts ~= alias)
 counts.value=counts.value+1
 stage=stage+1
 e.self:Say(counts.value..":"..alias.value)
end`, "2:0"},
		{"joined_tables", `local counts={value=0}
local alias={value=0}
local stage=0
function event_signal(e)
 if stage==0 then alias=counts end
 assert(counts == alias)
 counts.value=counts.value+1
 stage=stage+1
 e.self:Say("count="..alias.value)
end`, "count=2"},
		{"global_alias", `counts={value=0}
local alias=counts
function event_signal(e)
 assert(counts == alias)
 counts.value=counts.value+1
 e.self:Say("count="..alias.value)
end`, "count=2"},
		{"cleared_alias", `local counts={value=0}
local alias=counts
local stage=0
function event_signal(e)
 if stage==0 then alias=nil end
 assert(alias==nil)
 counts.value=counts.value+1
 stage=stage+1
 e.self:Say("count="..counts.value)
end`, "count=2"},
		{"shared_table_alias", `local counts={value=0}
local alias=counts
function event_signal(e)
 assert(counts == alias)
 counts.value=counts.value+1
 e.self:Say("count="..alias.value)
end`, "count=2"},
		{"nested_table_alias", `local counts={nested={value=0}}
local alias=counts.nested
function event_signal(e)
 assert(counts.nested == alias)
 counts.nested.value=counts.nested.value+1
 e.self:Say("count="..alias.value)
end`, "count=2"},
		{"distinct_table_keys", `local counts={[1]=0,[1.5]=10,["#1"]=100,["\000quest:number:1"]=1000}
function event_signal(e)
 for key,value in pairs(counts) do counts[key]=value+1 end
 e.self:Say(counts[1]..":"..counts[1.5]..":"..counts["#1"]..":"..counts["\000quest:number:1"])
end`, "2:12:102:1002"},
		{"table_helper", `local count=0
local helpers={}
function helpers.increment() count=count+1; return count end
helpers.self=helpers
function event_signal(e) e.self:Say("count="..helpers.increment()) end`, "count=2"},
		{"global_table_helpers", `local function counter(start)
 local count=start
 return function() count=count+1; return count end
end
helpers={first=counter(0), nested={second=counter(10)}}
function event_signal(e) e.self:Say(helpers.first()..":"..helpers.nested.second()) end`, "2:12"},
		{"nested", `local count=0
local function increment() count=count+1; return count end
local function helper(e) e.self:Say("count="..increment()) end
function event_signal(e) helper(e) end`, "count=2"},
		{"separate_closures", `local function counter(start)
 local count=start
 return function() count=count+1; return count end
end
local first,second=counter(0),counter(10)
function event_signal(e) e.self:Say(first()..":"..second()) end`, "2:12"},
		{"recursive_shared", `local count=0
local function helper(n) if n>0 then return helper(n-1) end; count=count+1; return count end
function event_spawn(e) count=helper(1) end
function event_signal(e) e.self:Say("count="..helper(2)) end`, "count=2"},
		{"cross_event_closures", `local function counter(start)
 local count=start
 return function() count=count+1; return count end
end
local first,second=counter(0),counter(10)
function event_spawn(e) first() end
function event_signal(e) e.self:Say(first()..":"..second()) end`, "2:11"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			bridge := NewLuaBridge(".")
			event := &LuaEvent{NPC: &NPCProxy{Name: "Counter"}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{}}
			firstHandler := "event_signal"
			if tc.name == "recursive_shared" || tc.name == "cross_event_closures" {
				firstHandler = "event_spawn"
			}
			first, err := bridge.ExecuteEventFromSource(tc.source, firstHandler, event)
			require.NoError(t, err)
			encoded, err := json.Marshal(first.ScriptState)
			require.NoError(t, err)
			require.NoError(t, json.Unmarshal(encoded, &event.ScriptState))
			second, err := bridge.ExecuteEventFromSource(tc.source, "event_signal", event)
			require.NoError(t, err)
			require.Contains(t, second.Responses, tc.want)
		})
	}
}

func TestLuaClearedStateStaysCleared(t *testing.T) {
	for _, declaration := range []string{"local stage = 'initial'", "stage = 'initial'"} {
		for _, handlers := range [][]string{{"event_spawn", "event_signal", "event_say"}, {"event_signal", "event_say", "event_say"}} {
			t.Run(declaration, func(t *testing.T) {
				source := declaration + `
function event_spawn(e) stage = 'ready' end
function event_signal(e) stage = nil end
function event_say(e) e.self:Say(tostring(stage)) end`
				event := &LuaEvent{NPC: &NPCProxy{Name: "State"}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{}}
				for _, handler := range handlers {
					capture, err := NewLuaBridge(".").ExecuteEventFromSource(source, handler, event)
					require.NoError(t, err)
					if handler == "event_say" {
						require.Contains(t, capture.Responses, "nil")
					}
					encoded, err := json.Marshal(capture.ScriptState)
					require.NoError(t, err)
					event.ScriptState = nil
					require.NoError(t, json.Unmarshal(encoded, &event.ScriptState))
				}
			})
		}
	}
}
