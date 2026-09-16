package quest

import (
	"github.com/stretchr/testify/require"
	"testing"
)

func TestQuestSpellCaptureRetainsTypedActorsAndConcreteNPCID(t *testing.T) {
	capture, err := NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e)
  e.self:Say(tostring(e.self:GetID()))
  e.self:CastSpell(17, e.other:GetID())
  e.self:CastSpell(17, e.self:GetID())
end`, &LuaEvent{NPC: &NPCProxy{ID: 9001}, Player: &PlayerProxy{ID: 101}, SpawnInstanceID: 5000000000001})
	require.NoError(t, err)
	require.Equal(t, []string{"5000000000001"}, capture.Responses)
	require.Len(t, capture.SpellCasts, 2)
	require.Equal(t, QuestSpellActor{CharacterID: 101}, capture.SpellCasts[0].Target)
	require.Equal(t, QuestSpellActor{NPCTypeID: 9001, SpawnInstanceID: 5000000000001}, capture.SpellCasts[0].Caster)
	require.Equal(t, capture.SpellCasts[0].Caster, capture.SpellCasts[1].Target)
}

func TestQuestActorNumericCollisionIsNotGuessed(t *testing.T) {
	capture, err := NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e)
  e.self:CastSpell(17, e.other:GetID())
end`, &LuaEvent{NPC: &NPCProxy{ID: 9001}, Player: &PlayerProxy{ID: 101}, SpawnInstanceID: 101})
	require.NoError(t, err)
	require.Equal(t, QuestSpellActor{}, capture.SpellCasts[0].Target)
}

func TestMergedQuestCapturesRebasePendingActorReferences(t *testing.T) {
	dst, src := NewQuestCapture(), NewQuestCapture()
	dst.Spawns = []QuestSpawnRequest{{NPCTypeID: 9001}}
	src.Spawns = []QuestSpawnRequest{{NPCTypeID: 9002}}
	src.Signals = []NPCSignal{{NPCID: 9002, PendingSpawnIndex: 1}}
	src.Depops = []QuestDepopRequest{{NPCTypeID: 9002, PendingSpawnIndex: 1}}
	src.SpellCasts = []QuestSpellCast{{Caster: QuestSpellActor{NPCTypeID: 9002, PendingSpawnIndex: 1}}}
	src.NPCMoves = []QuestNPCMoveRequest{{NPCTypeID: 9002, PendingSpawnIndex: 1}}
	src.HateChanges = []QuestHateChange{{Source: QuestSpellActor{NPCTypeID: 9002, PendingSpawnIndex: 1}, Target: QuestSpellActor{NPCTypeID: 9002, PendingSpawnIndex: 1}}}
	mergeQuestCapture(dst, src)
	require.Equal(t, 2, dst.Signals[0].PendingSpawnIndex)
	require.Equal(t, 2, dst.Depops[0].PendingSpawnIndex)
	require.Equal(t, 2, dst.SpellCasts[0].Caster.PendingSpawnIndex)
	require.Equal(t, 1, src.Signals[0].PendingSpawnIndex)
	require.Equal(t, 2, dst.NPCMoves[0].PendingSpawnIndex)
	require.Equal(t, 2, dst.HateChanges[0].Source.PendingSpawnIndex)
	require.Equal(t, 2, dst.HateChanges[0].Target.PendingSpawnIndex)
	require.Equal(t, 1, src.NPCMoves[0].PendingSpawnIndex)
	require.Equal(t, 1, src.HateChanges[0].Source.PendingSpawnIndex)
}

func TestQuestCaptureRetainsPendingCombatAndDeferredOnlyEffects(t *testing.T) {
	require.True(t, captureHasEffects(&QuestCapture{HateChanges: []QuestHateChange{{Hate: 1}}}))
	require.True(t, captureHasEffects(&QuestCapture{DeferredAPIs: []string{"eq.follow"}}), "unsupported callback must reach preflight, not disappear as an empty result")
}

func TestMergedQuestActorCommandsPreserveOrderAcrossCallbacks(t *testing.T) {
	const source = `function event_say(e)
local child = eq.spawn2(9002,0,0,1,2,3,4)
child:MoveTo(5,6,7,8,true)
child:AddToHateList(e.other,1)
end`
	merged := NewQuestCapture()
	for range 2 {
		capture, err := NewLuaBridge(".").ExecuteSayFromSource(source, &LuaEvent{NPC: &NPCProxy{ID: 9001}, Player: &PlayerProxy{ID: 123}, SpawnInstanceID: 6001})
		require.NoError(t, err)
		mergeQuestCapture(merged, capture)
		require.Equal(t, 1, capture.NPCMoves[0].Order)
		require.Equal(t, 2, capture.HateChanges[0].Order)
	}
	require.Equal(t, 1, merged.NPCMoves[0].Order)
	require.Equal(t, 2, merged.HateChanges[0].Order)
	require.Equal(t, 3, merged.NPCMoves[1].Order)
	require.Equal(t, 4, merged.HateChanges[1].Order)
	require.Equal(t, 2, merged.HateChanges[1].Source.PendingSpawnIndex)
}
