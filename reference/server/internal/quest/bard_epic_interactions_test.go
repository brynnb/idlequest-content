package quest

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestBardForparOptionalIntroductionVariants(t *testing.T) {
	for _, zone := range []string{"steamfont", "steamfontmts"} {
		t.Run(zone, func(t *testing.T) {
			source := readOverrideLua(t, "modified-upstream", zone, "Forpar_Fizfla")
			event := progressionEvent(PlayerProxy{ID: 123, Name: "Bard", ClassID: 8, CharLevel: 50})
			event.Message = "what components"
			capture, err := NewLuaBridge("upstream/projecteq").ExecuteSayFromSource(source, event)
			require.NoError(t, err)
			require.Equal(t, []QuestReward{{ItemID: 20380, Count: 1}}, capture.Items)
			require.Contains(t, source, "head, the body and the undead dragon gut")
		})
	}
}

func TestBardMaligarReplacementAttacksQuestOwner(t *testing.T) {
	source := readOverrideLua(t, "idlequest-authored", "qey2hh1", "Maligars_Enraged_Doppleganger")
	event := progressionEvent(PlayerProxy{ID: 123, Name: "QuestOwner", ClassID: 8, CharLevel: 50})
	capture, err := NewLuaBridge("upstream/projecteq").ExecuteEventFromSource(source, "event_spawn", event)
	require.NoError(t, err)
	require.Equal(t, []QuestAttackRequest{{PlayerName: "QuestOwner"}}, capture.Attacks)
	require.Empty(t, capture.HateChanges)
}
