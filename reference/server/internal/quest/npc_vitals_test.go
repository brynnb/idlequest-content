package quest

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestNPCVitalsUseExactLiveSnapshotWithoutMutatingSource(t *testing.T) {
	for _, hp := range []int64{25, 0} {
		event := progressionEvent(PlayerProxy{})
		event.NPC = &NPCProxy{ID: 9001, HP: 10000, MaxHP: 10000}
		event.SpawnInstanceID = 7001
		event.NPCVitals = &QuestNPCVitals{NPCTypeID: 9001, SpawnInstanceID: 7001, HP: hp, MaxHP: 200}
		original := event.NPC
		capture, err := NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e)
assert(e.self:GetMaxHP() == 200)
assert(e.self:GetHPRatio() == e.self:GetHP() / 2)
if e.self:GetHPRatio() < 20 then e.self:Say("wounded") end
end`, event)
		require.NoError(t, err)
		require.Equal(t, []string{"wounded"}, capture.Responses)
		require.Equal(t, int64(10000), original.HP)
		require.Equal(t, hp, event.NPC.HP)
	}
}

func TestNPCVitalsRejectMismatchedSnapshotsBeforeQuestEffects(t *testing.T) {
	for _, snapshot := range []QuestNPCVitals{
		{NPCTypeID: 9002, SpawnInstanceID: 7001, MaxHP: 100},
		{NPCTypeID: 9001, SpawnInstanceID: 7002, MaxHP: 100},
		{NPCTypeID: 9001, MaxHP: 100},
		{NPCTypeID: 9001, SpawnInstanceID: 7001},
	} {
		event := progressionEvent(PlayerProxy{})
		event.NPC = &NPCProxy{ID: 9001}
		event.SpawnInstanceID = 7001
		event.NPCVitals = &snapshot
		capture, err := NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e) e.other:SummonItem(1001) end`, event)
		require.ErrorContains(t, err, "vitals snapshot")
		require.Nil(t, capture)
	}
}

func TestNPCVitalsDialoguePreviewUsesLiveHealthAndIsIsolated(t *testing.T) {
	event := progressionEvent(PlayerProxy{})
	event.NPC = &NPCProxy{ID: 9001, HP: 1000, MaxHP: 1000}
	event.SpawnInstanceID = 7001
	event.NPCVitals = &QuestNPCVitals{NPCTypeID: 9001, SpawnInstanceID: 7001, HP: 25, MaxHP: 200}
	options, err := NewLuaBridge(".").DiscoverDialogueOptions(`function event_say(e)
if e.self:GetHPRatio() < 20 and e.message:findi("help") then e.other:SummonItem(1001) end
end`, event)
	require.NoError(t, err)
	require.Equal(t, []DialogueOption{{Text: "help", Keyword: "help"}}, options)
	require.Equal(t, int64(1000), event.NPC.HP)
	require.Nil(t, event.NPC.Capture)
}

func TestNPCVitalsUnavailableRatioCannotBeHiddenByPcall(t *testing.T) {
	event := progressionEvent(PlayerProxy{})
	event.NPC = &NPCProxy{ID: 9001}
	capture, err := NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e)
pcall(function() e.self:GetHPRatio() end)
e.other:SummonItem(1001)
end`, event)
	require.ErrorContains(t, err, "positive maximum HP")
	require.Nil(t, capture)
}
