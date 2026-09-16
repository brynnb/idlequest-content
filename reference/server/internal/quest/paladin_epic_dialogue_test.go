package quest

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestPeasantWaterDeliveryOptions(t *testing.T) {
	for _, zone := range []string{"freportw", "freeporteast"} {
		for _, tc := range []struct {
			phrase, class, response string
			reward                  bool
		}{
			{"hail", "Paladin", "water", false},
			{"water", "Paladin", "take this water to him", false},
			{"take this water to him", "Paladin", "Surely you are a pure soul", true},
			{"I will take it to him", "Paladin", "Surely you are a pure soul", true},
			{"I will take this water to him", "Paladin", "Surely you are a pure soul", true},
			{"take this water to him", "Warrior", "", false},
		} {
			t.Run(zone+"/"+tc.class+"/"+tc.phrase, func(t *testing.T) {
				event := progressionEvent(PlayerProxy{ID: 123, CharClass: tc.class})
				event.Message = tc.phrase
				capture, err := NewLuaBridge("upstream/projecteq").ExecuteSayFromSource(
					readOverrideLua(t, "modified-upstream", zone, "peasant_woman"), event)
				require.NoError(t, err)
				if tc.response != "" {
					require.Contains(t, strings.Join(capture.Responses, " "), tc.response)
				}
				if tc.reward {
					require.Equal(t, []QuestReward{{ItemID: 29008, Count: 1}}, capture.Items)
				} else {
					require.Empty(t, capture.Items)
				}
			})
		}
	}
}

func TestSoulFireRestoredHandIns(t *testing.T) {
	for _, tc := range []struct {
		zone, name string
		items      []int
		reward     int
	}{
		{"highkeep", "Bank_Clerk_Jaylin", []int{12143}, 18936},
		{"highkeep", "Bank_Clerk_Jaylin", []int{12193}, 13323},
		{"paw", "Brother_Hayle", []int{18936}, 18937},
		{"paw", "Brother_Hayle", []int{18937, 13947, 18828, 12197}, 5504},
	} {
		t.Run(tc.zone+"/"+tc.name, func(t *testing.T) {
			e := progressionEvent(PlayerProxy{ID: 123, CharClass: "Paladin", ClassID: 3})
			e.Trade = &TradeProxy{Items: append(append([]int{}, tc.items...), 1001)}
			capture, err := NewLuaBridge("upstream/projecteq").ExecuteTradeFromSource(readOverrideLua(t, "modified-upstream", tc.zone, tc.name), e)
			require.NoError(t, err)
			require.Equal(t, []QuestReward{{ItemID: tc.reward, Count: 1}}, capture.Items)
			require.Equal(t, []int{1001}, capture.CurrentTrade.Items)
		})
	}
}
