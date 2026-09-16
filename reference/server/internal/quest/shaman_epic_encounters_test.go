package quest

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestShamanGreaterSpiritsHaveDistinctIntroductions(t *testing.T) {
	for _, tc := range []struct{ script, phrase, want string }{
		{"a_greater_spirit", "i follow justice", "a follower of the Tribunal from the North"},
		{"a_greater_spirit_", "hail", "glad you trusted in our brother"},
	} {
		event := progressionEvent(PlayerProxy{ID: 123, Name: "QuestOwner", CharClass: "Shaman", CharLevel: 50})
		event.Message = tc.phrase
		capture, err := NewLuaBridge("upstream/projecteq").ExecuteSayFromSource(readOverrideLua(t, "modified-upstream", "freportn", tc.script), event)
		require.NoError(t, err)
		require.Contains(t, strings.Join(capture.Responses, " "), tc.want)
		require.Empty(t, capture.Items)
	}
}

func TestShamanAdvisorDeathSummonsBlackDireAtCanyon(t *testing.T) {
	source := readOverrideLua(t, "converted-perl", "mistmoore", "an_advisor")
	event := progressionEvent(PlayerProxy{ID: 123, Name: "QuestOwner", CharClass: "Shaman", CharLevel: 50})
	capture, err := NewLuaBridge("upstream/projecteq").ExecuteEventFromSource(source, "event_death_complete", event)
	require.NoError(t, err)
	require.Len(t, capture.Spawns, 1)
	require.EqualValues(t, 59129, capture.Spawns[0].NPCTypeID)
	require.Equal(t, float64(-164), capture.Spawns[0].X)
	require.Equal(t, float64(89), capture.Spawns[0].Y)
	require.InDelta(t, -220.880005, capture.Spawns[0].Z, 0.000001)
	require.Equal(t, float64(113), capture.Spawns[0].Heading)
	require.Empty(t, capture.Attacks, "Black Dire awaits the player's interaction")
}

func TestShamanKirnSpawnStartsOriginalAttack(t *testing.T) {
	source := readOverrideLua(t, "converted-perl", "hole", "#High_Scale_Kirn")
	for _, class := range []string{"Shaman", "Warrior"} {
		t.Run(class, func(t *testing.T) {
			event := progressionEvent(PlayerProxy{ID: 123, Name: "QuestOwner", CharClass: class, CharLevel: 50})
			capture, err := NewLuaBridge("upstream/projecteq").ExecuteEventFromSource(source, "event_spawn", event)
			require.NoError(t, err)
			if class == "Shaman" {
				require.Equal(t, []QuestAttackRequest{{PlayerName: "QuestOwner"}}, capture.Attacks)
			} else {
				require.Empty(t, capture.Attacks)
			}
			require.Empty(t, capture.HateChanges, "Attack must use its supported runtime path, not deferred numeric hate")
		})
	}
}

func TestShamanCityMistReplacementsAttackQuestOwner(t *testing.T) {
	for _, name := range []string{"#Neh-Ashiir_", "#Lord_Rak-Ashiir_"} {
		t.Run(name, func(t *testing.T) {
			source := readOverrideLua(t, "idlequest-authored", "citymist", name)
			event := progressionEvent(PlayerProxy{ID: 123, Name: "QuestOwner", CharClass: "Shaman", CharLevel: 50})
			capture, err := NewLuaBridge("upstream/projecteq").ExecuteEventFromSource(source, "event_spawn", event)
			require.NoError(t, err)
			require.Equal(t, []QuestAttackRequest{{PlayerName: "QuestOwner"}}, capture.Attacks)
			require.Empty(t, capture.HateChanges)
			require.Empty(t, capture.Spawns, "The hand-in already created this exact hostile replacement")
		})
	}
}
