package quest

import (
	"os"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func discoverOptionsForTest(t *testing.T, bridge *LuaBridge, source string) []DialogueOption {
	t.Helper()
	if !strings.Contains(source, "function event_say") {
		source = "function event_say(e)\n" + source + "\nend"
	}
	options, err := bridge.DiscoverDialogueOptions(source, &LuaEvent{Player: &PlayerProxy{CharLevel: 1}})
	require.NoError(t, err)
	return options
}

func TestDialogueDiscoveryUsesRealGatesAndDoesNotApplyEffects(t *testing.T) {
	bridge := NewLuaBridge(".")
	source := `function event_say(e)
 eq.set_global("preview_only", "yes", 5, "F")
 e.other:SummonItem(1001)
 if e.other:GetLevel() >= 50 and e.other:GetClass() == 5 and e.other:HasItem(123) and eq.get_qglobals().ready == "yes" then
   if e.message:findi("secret trial") then
     error("the branch body must not run")
   end
 end
end`
	event := &LuaEvent{NPC: &NPCProxy{}, Player: &PlayerProxy{CharLevel: 60, ClassID: 5, Inventory: map[int]bool{123: true}}, Globals: map[string]string{"ready": "yes"}}
	before, err := cloneDialogueEvent(event)
	require.NoError(t, err)
	options, err := bridge.DiscoverDialogueOptions(source, event)
	require.NoError(t, err)
	require.Equal(t, []DialogueOption{{Text: "secret trial", Keyword: "secret trial"}}, options)
	assert.Equal(t, before, event, "preview must not attach captures or mutate shared state")
	for _, change := range []func(*LuaEvent){
		func(e *LuaEvent) { e.Player.CharLevel = 1 },
		func(e *LuaEvent) { e.Player.ClassID = 1 },
		func(e *LuaEvent) { delete(e.Player.Inventory, 123) },
		func(e *LuaEvent) { delete(e.Globals, "ready") },
	} {
		copyEvent, err := cloneDialogueEvent(event)
		require.NoError(t, err)
		change(copyEvent)
		options, err := bridge.DiscoverDialogueOptions(source, copyEvent)
		require.NoError(t, err)
		assert.Empty(t, options)
	}
}

func TestDialogueDiscoveryLhrancWithHostileFaction(t *testing.T) {
	source, err := os.ReadFile("upstream/projecteq/citymist/Lhranc.lua")
	require.NoError(t, err)
	options, err := NewLuaBridge(".").DiscoverDialogueOptions(string(source), &LuaEvent{NPC: &NPCProxy{PrimaryFaction: 404}, Player: &PlayerProxy{Factions: map[int]int{404: -2000}}})
	require.NoError(t, err)
	assert.Equal(t, []DialogueOption{{Text: "curse", Keyword: "curse"}, {Text: "cure", Keyword: "cure"}}, options)
}

func TestDialogueDiscoveryDoesNotScanOtherHandlersOrStringLiterals(t *testing.T) {
	options, err := NewLuaBridge(".").DiscoverDialogueOptions(`function event_timer(e) if e.message:findi("not a response") then end end`, &LuaEvent{})
	require.NoError(t, err)
	assert.Empty(t, options)
	options, err = NewLuaBridge(".").DiscoverDialogueOptions(`function event_say(e)
 --[[ if e.message:findi("comment") then end ]]
 local text = 'findi("string")'
 if e.message:findi("active") then end
end`, &LuaEvent{})
	require.NoError(t, err)
	assert.Equal(t, []DialogueOption{{Text: "active", Keyword: "active"}}, options)
}

func TestDialogueDiscoveryComposesNestedPhrasesAndPreservesGates(t *testing.T) {
	bridge := NewLuaBridge(".")
	source := `function event_say(e)
 if e.message:findi("follow") then
   eq.set_global("preview_only", "yes", 5, "F")
   if e.other:GetLevel() >= 10 and e.message:findi("tunare") then
     error("selected response body must not run during discovery")
   end
 end
end`
	event := &LuaEvent{Player: &PlayerProxy{CharLevel: 10}}
	before, err := cloneDialogueEvent(event)
	require.NoError(t, err)
	options, err := bridge.DiscoverDialogueOptions(source, event)
	require.NoError(t, err)
	require.Contains(t, options, DialogueOption{Text: "follow tunare", Keyword: "follow tunare"})
	require.NotContains(t, options, DialogueOption{Text: "tunare", Keyword: "tunare"})
	require.Equal(t, before, event)
	event.Player.CharLevel = 1
	options, err = bridge.DiscoverDialogueOptions(source, event)
	require.NoError(t, err)
	require.NotContains(t, options, DialogueOption{Text: "follow tunare", Keyword: "follow tunare"})
}

func TestMadameSerenaNestedOptionsReachRealReplies(t *testing.T) {
	source := readOverrideLua(t, "modified-upstream", "qeynos", "Madame_Serena")
	bridge := NewLuaBridge(".")
	options, err := bridge.DiscoverDialogueOptions(source, &LuaEvent{})
	require.NoError(t, err)
	require.NotContains(t, options, DialogueOption{Text: "follow", Keyword: "follow"}, "routing prefix has no response")
	require.Contains(t, options, DialogueOption{Text: "follow marr", Keyword: "follow marr"}, "Which Marr fallback remains useful")
	for phrase, reply := range map[string]string{
		"follow tunare":         "mother of all elves",
		"follow marr erollisi":  "ways of love",
		"follow marr mithaniel": "true valor",
	} {
		require.Contains(t, options, DialogueOption{Text: phrase, Keyword: phrase})
		capture, err := bridge.ExecuteSayFromSource(source, &LuaEvent{Message: phrase})
		require.NoError(t, err)
		require.Contains(t, strings.Join(capture.Responses, " "), reply)
	}
}

func TestNestedDialogueCannotBypassGateUsingItsRoutingPrefix(t *testing.T) {
	source := `function event_say(e)
 if e.message:findi("join") then
   if e.other:GetLevel() >= 10 then
     if e.message:findi("order") then e.self:Say("Welcome") end
   end
 end
end`
	bridge := NewLuaBridge(".")
	options, err := bridge.DiscoverDialogueOptions(source, &LuaEvent{Player: &PlayerProxy{CharLevel: 1}})
	require.NoError(t, err)
	require.Empty(t, options)
	options, err = bridge.DiscoverDialogueOptions(source, &LuaEvent{Player: &PlayerProxy{CharLevel: 10}})
	require.NoError(t, err)
	require.Equal(t, []DialogueOption{{Text: "join order", Keyword: "join order"}}, options)
}

func TestDialogueDiscoveryTimeoutAndFailureDoNotOfferGuessedOptions(t *testing.T) {
	for _, source := range []string{
		`function event_say(e) while true do end; if e.message:findi("blocked") then end end`,
		`function event_say(e) error("bad data"); if e.message:findi("blocked") then end end`,
		`local io = require("io"); function event_say(e) if e.message:findi("blocked") then end end`,
	} {
		options, err := NewLuaBridge(".").DiscoverDialogueOptions(source, &LuaEvent{})
		require.Error(t, err)
		assert.Empty(t, options)
	}
}

func TestDialogueDiscoveryUsesSavedStateAndUpdatedGlobals(t *testing.T) {
	event := &LuaEvent{Globals: map[string]string{"old": "yes"}, ScriptState: map[string]any{"global:stage": float64(2)}}
	applyDialogueGlobals(event, &QuestCapture{Globals: map[string]GlobalUpdate{
		"old": {Delete: true}, "ready": {Value: "yes"},
	}})
	options, err := NewLuaBridge(".").DiscoverDialogueOptions(`stage = 0
function event_say(e)
 if stage == 2 and eq.get_qglobals().ready == "yes" and not eq.get_qglobals().old then
   if e.message:findi("next step") then stage = 3 end
 end
end`, event)
	require.NoError(t, err)
	assert.Equal(t, []DialogueOption{{Text: "next step", Keyword: "next step"}}, options)
	assert.Equal(t, float64(2), event.ScriptState["global:stage"])
}
