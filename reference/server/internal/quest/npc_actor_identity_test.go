package quest

import (
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestSpawnProxyInventoryDoesNotLeakIntoSummonerOrSibling(t *testing.T) {
	capture, err := NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e)
  local first = eq.spawn2(9001, 0, 0, 1, 2, 3, 4)
  local second = eq.spawn2(9001, 0, 0, 5, 6, 7, 8)
  -- Append enough requests to invalidate any pointer into the original slice.
  for i=1,20 do eq.spawn2(9002, 0, 0, i, 0, 0, 0) end
  first:AddItem(18099, 2)
  second:AddItem(1888, 1)
  first:AddItem(18099, 2)
  local unique = eq.unique_spawn(9003, 0, 0, 0, 0, 0, 0)
  unique:AddItem(1889, -1)
  e.self:AddItem(1890, 1)
end`, &LuaEvent{NPC: &NPCProxy{ID: 9001}, Player: &PlayerProxy{}, SpawnInstanceID: 5002})
	require.NoError(t, err)
	require.Equal(t, []NPCAddedLoot{{NPCID: 9001, ItemID: 18099, Count: 2}, {NPCID: 9001, ItemID: 18099, Count: 2}}, capture.Spawns[0].AddedLoot)
	require.Equal(t, []NPCAddedLoot{{NPCID: 9001, ItemID: 1888, Count: 1}}, capture.Spawns[1].AddedLoot)
	require.True(t, capture.Spawns[22].Unique)
	require.Equal(t, []NPCAddedLoot{{NPCID: 9003, ItemID: 1889, Count: -1}}, capture.Spawns[22].AddedLoot)
	for _, spawn := range capture.Spawns[2:22] {
		require.Empty(t, spawn.AddedLoot)
	}
	want := []NPCAddedLoot{{NPCID: 9001, SpawnInstanceID: 5002, ItemID: 1890, Count: 1}}
	require.Equal(t, want, capture.NPCAddedLoot)
	items, err := NPCAddedLootFromScriptState(capture.ScriptState)
	require.NoError(t, err)
	require.Equal(t, want, items)
}

func TestNPCMethodsCaptureConcreteActorRatherThanTypeBroadcast(t *testing.T) {
	bridge := NewLuaBridge(".")
	capture, err := bridge.ExecuteSayFromSource(`function event_say(e)
  e.self:Signal(7)
  e.self:Depop()
  eq.signal(9001, 8)
end`, &LuaEvent{NPC: &NPCProxy{ID: 9001}, Player: &PlayerProxy{}, SpawnInstanceID: 5002})
	require.NoError(t, err)
	require.Equal(t, []NPCSignal{
		{NPCID: 9001, SignalID: 7, SpawnInstanceID: 5002},
		{NPCID: 9001, SignalID: 8},
	}, capture.Signals)
	require.Equal(t, []QuestDepopRequest{{NPCTypeID: 9001, SpawnInstanceID: 5002}}, capture.Depops)
}

func TestNPCAddedLootRetainsIdentityThroughPersistence(t *testing.T) {
	capture, err := NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e)
  e.self:AddItem(18099, 2)
end`, &LuaEvent{NPC: &NPCProxy{ID: 93083}, Player: &PlayerProxy{}, SpawnInstanceID: 5002})
	require.NoError(t, err)
	want := []NPCAddedLoot{{NPCID: 93083, SpawnInstanceID: 5002, ItemID: 18099, Count: 2}}
	require.Equal(t, want, capture.NPCAddedLoot)
	encoded, err := json.Marshal(capture.ScriptState)
	require.NoError(t, err)
	var restored map[string]any
	require.NoError(t, json.Unmarshal(encoded, &restored))
	items, err := npcAddedLootForActor(restored, 93083, 5002)
	require.NoError(t, err)
	require.Equal(t, want, items)
	items, err = npcAddedLootForActor(restored, 93083, 5003)
	require.ErrorContains(t, err, "belongs to spawn 5002, not 5003")
	require.Nil(t, items, "same NPC type does not make another actor's inventory eligible")

	// Historical inventory has no embedded spawn ID, but was loaded through
	// the exact owner/zone/instance/spawn database key, not a type fallback.
	legacy := map[string]any{NPCAddedLootScriptStateKey: []NPCAddedLoot{{NPCID: 93083, ItemID: 18099, Count: 1}}}
	items, err = npcAddedLootForActor(legacy, 93083, 5002)
	require.NoError(t, err)
	require.Len(t, items, 1)
}

func TestMalformedNPCInventoryCannotBecomeAnEmptyCorpseOrBeOverwritten(t *testing.T) {
	state := map[string]any{NPCAddedLootScriptStateKey: []any{map[string]any{"npcId": 93083, "itemId": 18099, "count": "broken"}}}
	items, err := npcAddedLootForActor(state, 93083, 5002)
	require.ErrorContains(t, err, "decode quest NPC inventory")
	require.Nil(t, items)
	before, err := json.Marshal(state)
	require.NoError(t, err)
	capture, err := NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e)
  e.self:AddItem(18099, 1)
end`, &LuaEvent{NPC: &NPCProxy{ID: 93083}, Player: &PlayerProxy{}, SpawnInstanceID: 5002, ScriptState: state})
	require.ErrorContains(t, err, "decode quest NPC inventory")
	require.Nil(t, capture)
	after, err := json.Marshal(state)
	require.NoError(t, err)
	require.Equal(t, string(before), string(after))
	for _, bad := range []NPCAddedLoot{{NPCID: 93083, ItemID: 0}, {NPCID: 93083, ItemID: 18099, Count: -2}} {
		_, err := npcAddedLootForActor(map[string]any{NPCAddedLootScriptStateKey: []NPCAddedLoot{bad}}, 93083, 5002)
		require.ErrorContains(t, err, "invalid quest NPC inventory")
	}
}
