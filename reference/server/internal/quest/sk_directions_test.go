package quest

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

// Expectations come from the July 17 P99 Shadow Knight Epic Quest snapshot,
// not the abbreviated converted scripts. Assert objectives, not exact prose.
func TestSKDialogueRetainsNextObjectives(t *testing.T) {
	for _, tc := range []struct {
		zone, npc, message string
		items              []int
		mentions           []string
		reward             int
	}{
		{"paineel", "Duriek_Bloodpool", "where was he searching?", nil, []string{"key", "tome", "ruins"}, 0},
		{"paineel", "Duriek_Bloodpool", "", []int{18099}, []string{"apprentice", "replace"}, 0},
		{"paineel", "Duriek_Bloodpool", "", []int{14365}, []string{"Ghoulbane", "apprentice", "search"}, 0},
		{"paineel", "Duriek_Bloodpool", "", []int{14382}, []string{"tome", "items"}, 0},
		{"paineel", "Duriek_Bloodpool", "", []int{5403, 11609, 5430, 14366}, []string{"Lhranc"}, 14367},
		{"kerraridge", "Marl_Kastane", "What prophecy?", nil, []string{"seal", "Gerot", "Paineel"}, 14375},
		{"paineel", "Gerot_Kastane", "hail", nil, []string{"physical head", "valiant warrior", "materials"}, 0},
	} {
		t.Run(tc.npc+tc.message+strings.Join(tc.mentions, "-"), func(t *testing.T) {
			bridge := NewLuaBridge("upstream/projecteq")
			bridge.RequireImplementedEffects = true
			event := progressionEvent(PlayerProxy{Name: "Knight", ClassID: 5, CharClass: "Shadow Knight", Factions: map[int]int{404: -2000}})
			event.Message = tc.message
			handler := "event_say"
			if tc.items != nil {
				handler = "event_trade"
				event.Trade = &TradeProxy{Items: append([]int(nil), tc.items...)}
			}
			capture, err := bridge.ExecuteEventFromSource(readOverrideLua(t, "converted-perl", tc.zone, tc.npc), handler, event)
			require.NoError(t, err)
			text := strings.Join(capture.Responses, " ")
			for _, mention := range tc.mentions {
				require.Contains(t, text, mention)
			}
			if tc.items != nil {
				require.Empty(t, capture.CurrentTrade.Items)
			}
			if tc.reward == 0 {
				require.Empty(t, capture.Items)
			} else {
				require.Len(t, capture.Items, 1)
				require.Equal(t, tc.reward, capture.Items[0].ItemID)
			}
		})
	}
}
