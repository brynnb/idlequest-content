package quest

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestMonkEpicEligibilityBeforeConsumption(t *testing.T) {
	for _, step := range []struct {
		zone, npc string
		items     []int
		reward    int
	}{
		{"erudnext", "Tomekeeper_Danl", []int{18195}, 1682},
		{"trakanon", "Kaiaren", []int{1683}, 1683},
		{"trakanon", "Kaiaren", []int{1684}, 1684},
		{"trakanon", "#Kaiaren", []int{1683}, 1689},
		{"trakanon", "#Kaiaren", []int{1684}, 1684},
		{"trakanon", "#Kaiaren", []int{1688, 1689}, 10652},
		{"lakerathe", "Deep", []int{1686}, 1686},
		{"airplane", "a_presence", []int{1684}, 0},
		{"lakeofillomen", "Astral_Projection", []int{1687}, 0},
	} {
		for _, player := range []PlayerProxy{
			{ID: 123, CharClass: "Monk", CharLevel: 45},
			{ID: 123, CharClass: "Warrior", CharLevel: 46},
			{ID: 123, CharClass: "Monk", CharLevel: 46},
		} {
			player.Name = "QuestTester"
			e := progressionEvent(player)
			e.Trade = &TradeProxy{Items: append([]int{}, step.items...)}
			capture, err := NewLuaBridge("upstream/projecteq").ExecuteTradeFromSource(readOverrideLua(t, "modified-upstream", step.zone, step.npc), e)
			require.NoError(t, err)
			if player.CharClass == "Monk" && player.CharLevel == 46 {
				require.Empty(t, capture.CurrentTrade.Items)
				if step.reward != 0 {
					require.Equal(t, []QuestReward{{ItemID: step.reward, Count: 1}}, capture.Items)
				} else {
					require.Empty(t, capture.Items)
					require.NotEmpty(t, capture.Spawns)
				}
			} else {
				require.Equal(t, step.items, capture.CurrentTrade.Items, "%s must retain rejected %v", step.npc, step.items)
				require.Empty(t, capture.Items)
				require.Empty(t, capture.Spawns)
				require.Empty(t, capture.Attacks)
			}
		}
	}
}

func TestMonkProjectionDoesNotRequireOptionalDeepVisit(t *testing.T) {
	for _, globals := range []map[string]string{nil, {"Trunt": "1"}} {
		e := progressionEvent(PlayerProxy{ID: 123, Name: "QuestTester", CharClass: "Monk", CharLevel: 50})
		e.Globals = globals
		e.Trade = &TradeProxy{Items: []int{1686, 1001}}
		capture, err := NewLuaBridge("upstream/projecteq").ExecuteTradeFromSource(readOverrideLua(t, "modified-upstream", "overthere", "Astral_Projection"), e)
		require.NoError(t, err)
		require.Equal(t, []QuestReward{{ItemID: 1687, Count: 1}}, capture.Items)
		require.Equal(t, []int{1001}, capture.CurrentTrade.Items)
	}
}

func TestMonkDanlDoesNotExposeLaterEraEpic(t *testing.T) {
	source := readOverrideLua(t, "modified-upstream", "erudnext", "Tomekeeper_Danl")
	bridge := NewLuaBridge("upstream/projecteq")
	for _, message := range []string{"power of the immortals", "disciple of Kaiaren", "vortix", "book"} {
		e := progressionEvent(PlayerProxy{ID: 123, Name: "QuestTester", CharClass: "Monk", CharLevel: 60})
		e.Globals = map[string]string{"monk_epic": "3"}
		e.Message = message
		capture, err := bridge.ExecuteSayFromSource(source, e)
		require.NoError(t, err)
		require.Empty(t, capture.Responses, message)
		require.Empty(t, capture.Globals)
	}
	e := progressionEvent(PlayerProxy{ID: 123, Name: "QuestTester", CharClass: "Monk", CharLevel: 60})
	e.Globals = map[string]string{"monk_epic": "2"}
	e.Trade = &TradeProxy{Items: []int{48132}}
	capture, err := bridge.ExecuteTradeFromSource(source, e)
	require.NoError(t, err)
	require.Equal(t, []int{48132}, capture.CurrentTrade.Items)
	require.Empty(t, capture.Items)
	require.Empty(t, capture.Globals)
}
