package quest

import (
	"os"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestLeraenaPawsRestoresVeliousBranchWithoutLosingClassicRewards(t *testing.T) {
	source, err := os.ReadFile("overrides/lua/modified-upstream/erudnext/Leraena_Shelyrak.lua")
	require.NoError(t, err)
	bridge := NewLuaBridge("upstream/projecteq")
	bridge.RequireImplementedEffects = true
	event := progressionEvent(PlayerProxy{CharLevel: 6, ClassID: 3, Factions: map[int]int{298: -2000}})
	for message, expected := range map[string]string{
		"hail": "[kobold shaman]", "kobold shaman": "[slay the kobold shaman]",
		"slay the kobold shaman": "three Odd Kobold Paws",
	} {
		event.Message = message
		capture, err := bridge.ExecuteSayFromSource(string(source), event)
		require.NoError(t, err)
		require.Contains(t, capture.Responses[0], expected)
	}
	for _, count := range []int{0, 1, 2, 3, 4} {
		event.Trade = &TradeProxy{}
		for i := 0; i < count; i++ {
			event.Trade.Items = append(event.Trade.Items, 13883)
		}
		capture, err := bridge.ExecuteTradeFromSource(string(source), event)
		require.NoError(t, err)
		if count < 3 {
			require.Empty(t, capture.Items)
			require.Len(t, capture.CurrentTrade.Items, count)
			require.Zero(t, capture.Exp)
			require.Empty(t, capture.Factions)
			require.Equal(t, QuestCurrency{}, capture.Currency)
		} else {
			require.Len(t, capture.CurrentTrade.Items, count-3)
			require.Len(t, capture.Items, 1)
			require.Contains(t, []int{15213, 15011}, capture.Items[0].ItemID)
			require.Equal(t, 1, capture.Items[0].Count)
			require.EqualValues(t, 500, capture.Exp)
			require.Equal(t, QuestCurrency{Silver: 17}, capture.Currency)
			require.Equal(t, []FactionReward{{298, 20}, {266, 5}, {265, -5}}, capture.Factions)
		}
	}
	for item, reward := range map[int]int{18723: 13546} {
		event.Trade = &TradeProxy{Items: []int{item}}
		capture, err := bridge.ExecuteTradeFromSource(string(source), event)
		require.NoError(t, err)
		require.Len(t, capture.Items, 1)
		require.Equal(t, reward, capture.Items[0].ItemID)
	}
}
