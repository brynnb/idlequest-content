package quest

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestNecromancerTrialReplacementsAttackQuestOwner(t *testing.T) {
	for _, variant := range []struct{ origin, name string }{
		{"converted-perl", "a_failed_apprentice"},
		{"idlequest-authored", "a_tortured_soul"},
	} {
		t.Run(variant.name, func(t *testing.T) {
			source := readOverrideLua(t, variant.origin, "lakerathe", variant.name)
			event := progressionEvent(PlayerProxy{ID: 123, Name: "QuestOwner", ClassID: 11, CharLevel: 60})
			capture, err := NewLuaBridge("upstream/projecteq").ExecuteEventFromSource(source, "event_spawn", event)
			require.NoError(t, err)
			require.Equal(t, []QuestAttackRequest{{PlayerName: "QuestOwner"}}, capture.Attacks)
			require.Empty(t, capture.HateChanges)
			require.Empty(t, capture.Spawns)
		})
	}
}

func TestNecromancerReviewedDirectionsDoNotRestoreLaterEpic(t *testing.T) {
	source := readOverrideLua(t, "converted-perl", "lakerathe", "Kazen_Fecae")
	event := progressionEvent(PlayerProxy{ID: 123, Name: "QuestOwner", ClassID: 11, CharLevel: 60})
	event.Globals["Soulwhisper"] = "1"
	event.Message = "hail"
	capture, err := NewLuaBridge("upstream/projecteq").ExecuteSayFromSource(source, event)
	require.NoError(t, err)
	require.Empty(t, capture.Items, "Epic 1.5 must stay excluded even with an old later-era flag")
	require.NotContains(t, source, "SummonItem(9831)")
	require.Contains(t, source, "give them to my assistant Emkel Kabae")
	require.Contains(t, readOverrideLua(t, "converted-perl", "swampofnohope", "Ssessthrass"), "deep in Chardok")
}
