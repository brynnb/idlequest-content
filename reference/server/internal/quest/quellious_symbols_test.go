package quest

import (
	"os"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestQuelliousSymbolTurnIns(t *testing.T) {
	for _, tc := range []struct {
		name, path     string
		level          int
		given, rewards []int
	}{
		{"initiate", "overrides/lua/modified-upstream/erudnext/Leraena_Shelyrak.lua", 10, []int{14582}, []int{1564}},
		{"disciple below level", "overrides/lua/modified-upstream/erudnext/Leraena_Shelyrak.lua", 19, []int{14583, 1564}, nil},
		{"disciple at level", "overrides/lua/modified-upstream/erudnext/Leraena_Shelyrak.lua", 20, []int{14583, 1564}, []int{1565}},
		{"missing initiate", "overrides/lua/modified-upstream/erudnext/Leraena_Shelyrak.lua", 20, []int{14583}, nil},
		{"missing bronze bag", "overrides/lua/modified-upstream/erudnext/Leraena_Shelyrak.lua", 20, []int{1564}, nil},
		{"first letter", "overrides/lua/modified-upstream/erudnext/Leraena_Shelyrak.lua", 20, []int{14585}, []int{14585, 1772}},
		{"glyssa letter", "overrides/lua/modified-upstream/freportw/Glyssa_Sonshaw.lua", 20, []int{14585, 1772}, []int{14585, 1779}},
		{"glyssa missing necklace", "overrides/lua/modified-upstream/freportw/Glyssa_Sonshaw.lua", 20, []int{1772}, nil},
		{"translation", "upstream/projecteq/akanon/Drigaz_Grumblegrowl.lua", 20, []int{14585, 1779}, []int{1780}},
		{"regent", "overrides/lua/modified-upstream/erudnext/Leraena_Shelyrak.lua", 20, []int{1780, 1781, 1565}, []int{1566}},
		{"regent missing doctrine", "overrides/lua/modified-upstream/erudnext/Leraena_Shelyrak.lua", 20, []int{1780, 1565}, nil},
	} {
		t.Run(tc.name, func(t *testing.T) {
			source, err := os.ReadFile(tc.path)
			require.NoError(t, err)
			bridge := NewLuaBridge("upstream/projecteq")
			bridge.RequireImplementedEffects = true
			event := progressionEvent(PlayerProxy{CharLevel: tc.level, ClassID: 2, Factions: map[int]int{298: -2000, 220: -2000, 240: -2000}})
			// An unrelated offered item must survive every successful hand-in too.
			event.Trade = &TradeProxy{Items: append(append([]int{}, tc.given...), 13883)}
			capture, err := bridge.ExecuteTradeFromSource(string(source), event)
			require.NoError(t, err)
			var ids []int
			for _, reward := range capture.Items {
				ids = append(ids, reward.ItemID)
				require.Equal(t, 1, reward.Count)
			}
			require.ElementsMatch(t, tc.rewards, ids)
			if len(tc.rewards) == 0 {
				require.ElementsMatch(t, append(append([]int{}, tc.given...), 13883), capture.CurrentTrade.Items)
				require.Zero(t, capture.Exp)
				require.Empty(t, capture.Factions)
			} else {
				require.Equal(t, []int{13883}, capture.CurrentTrade.Items)
			}
		})
	}
}

func TestQuelliousDialogueSpecificTopicsBeatGenericShamanTopic(t *testing.T) {
	source, err := os.ReadFile("overrides/lua/modified-upstream/erudnext/Leraena_Shelyrak.lua")
	require.NoError(t, err)
	bridge := NewLuaBridge("upstream/projecteq")
	bridge.RequireImplementedEffects = true
	for _, phrase := range []string{"greater kobold shaman", "greater kobold shamen", "more powerful kobold shaman", "more powerful kobold shamen", "more powerful shamen"} {
		t.Run(phrase, func(t *testing.T) {
			event := progressionEvent(PlayerProxy{CharLevel: 20, ClassID: 2})
			event.Message = phrase
			capture, err := bridge.ExecuteSayFromSource(string(source), event)
			require.NoError(t, err)
			require.Len(t, capture.Items, 1)
			require.Equal(t, 17090, capture.Items[0].ItemID)
			require.Contains(t, capture.Responses[0], "eight")
		})
	}
}
