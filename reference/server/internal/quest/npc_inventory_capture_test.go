package quest

import (
	"github.com/stretchr/testify/require"
	"testing"
)

func TestCrossNPCInventoryCaptureMergesAndClearsWithoutChangingEventState(t *testing.T) {
	first := &QuestCapture{ExternalNPCAddedLoot: []NPCAddedLoot{{NPCID: 9002, SpawnInstanceID: 6002, ItemID: 18099, Count: 1}}}
	second := &QuestCapture{ExternalNPCAddedLoot: []NPCAddedLoot{{NPCID: 9003, SpawnInstanceID: 6003, ItemID: 1888, Count: 2}}}
	mergeQuestCapture(first, second)
	require.Len(t, first.ExternalNPCAddedLoot, 2)
	require.Empty(t, first.NPCAddedLoot)
	require.True(t, captureHasRuntimeEffects(first))
	clearQuestCaptureEffects(first)
	require.Empty(t, first.ExternalNPCAddedLoot)
	require.Len(t, second.ExternalNPCAddedLoot, 1)
}
