package quest

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestEnchanterSackDialogueStillRequiresSeal(t *testing.T) {
	source := readOverrideLua(t, "converted-perl", "firiona", "Nadia_Starfeast")
	for _, hasSeal := range []bool{false, true} {
		event := progressionEvent(PlayerProxy{ID: 123, ClassID: 14, CharLevel: 50,
			Inventory: map[int]bool{10604: hasSeal}})
		event.Message = "i need a sack"
		capture, err := NewLuaBridge("upstream/projecteq").ExecuteSayFromSource(source, event)
		require.NoError(t, err)
		if hasSeal {
			require.Equal(t, []QuestReward{{ItemID: 17861, Count: 1}}, capture.Items)
		} else {
			require.Empty(t, capture.Items, "Ally quest faction must not bypass item prerequisites")
		}
	}
}

func TestEnchanterInkVialStillRequiresLevelFifty(t *testing.T) {
	source := readOverrideLua(t, "converted-perl", "qcat", "Reania_Jukle")
	for _, level := range []int{49, 50} {
		event := progressionEvent(PlayerProxy{ID: 123, ClassID: 14, CharLevel: level})
		event.Message = "supply"
		capture, err := NewLuaBridge("upstream/projecteq").ExecuteSayFromSource(source, event)
		require.NoError(t, err)
		if level == 50 {
			require.Equal(t, []QuestReward{{ItemID: 10626, Count: 1}}, capture.Items)
		} else {
			require.Empty(t, capture.Items, "Ally quest faction must not bypass level prerequisites")
		}
	}
}
