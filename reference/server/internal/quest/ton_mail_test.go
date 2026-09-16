package quest

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestTonAcceptsIndependentMailDeliveries(t *testing.T) {
	source := readOverrideLua(t, "modified-upstream", "freportn", "Ton_Twostring")
	discovery := DiscoverTurnInScenarios(source)
	require.Empty(t, discovery.Unsupported)
	require.Len(t, discovery.Scenarios, 2)
	require.Equal(t, []int{18164}, discovery.Scenarios[0].Items)
	require.Equal(t, []int{18166}, discovery.Scenarios[1].Items)
	for _, tc := range []struct {
		name       string
		items      []int
		deliveries int
		remaining  []int
	}{
		{"High Keep", []int{18164}, 1, nil},
		{"Kelethin", []int{18166}, 1, nil},
		{"both routes", []int{18164, 18166}, 2, nil},
		{"unrelated item", []int{18164, 13005}, 1, []int{13005}},
		{"wrong destination", []int{18167}, 0, []int{18167}},
	} {
		t.Run(tc.name, func(t *testing.T) {
			e := progressionEvent(PlayerProxy{ID: 123, CharLevel: 2})
			e.Trade = &TradeProxy{Items: tc.items}
			capture, err := NewLuaBridge("upstream/projecteq").ExecuteTradeFromSource(source, e)
			require.NoError(t, err)
			require.ElementsMatch(t, tc.remaining, capture.CurrentTrade.Items)
			require.EqualValues(t, 100*tc.deliveries, capture.Exp)
			require.GreaterOrEqual(t, capture.Currency.Gold, 8*tc.deliveries)
			require.LessOrEqual(t, capture.Currency.Gold, 12*tc.deliveries)
			require.Len(t, capture.Factions, 5*tc.deliveries)
		})
	}
}

// Every destination must accept each of its routes without requiring another
// sender's letter. Older recipients may process one per Give; unprocessed mail
// must remain in the trade rather than being lost or rewarded twice.
func TestBardMailRoutesAcceptIndependentDeliveries(t *testing.T) {
	for _, tc := range []struct {
		zone, name, origin string
		items              []int
	}{
		{"qeynos", "Tralyn_Marsinger", "modified-upstream", []int{18150, 18151, 18153, 18154}},
		{"qeynos", "Eve_Marsinger", "", []int{18165}},
		{"highkeep", "Lislia_Goldtune", "", []int{18152, 18156}},
		{"freportn", "Felisity_Starbright", "", []int{18155, 18157, 18158, 18159}},
		{"gfaydark", "Jakum_Webdancer", "converted-perl", []int{18160, 18161, 18162, 18163}},
		{"gfaydark", "Idia", "converted-perl", []int{18167}},
	} {
		t.Run(tc.zone+"/"+tc.name, func(t *testing.T) {
			var source string
			if tc.origin == "" {
				source = readUpstreamLua(t, tc.zone, tc.name)
			} else {
				source = readOverrideLua(t, tc.origin, tc.zone, tc.name)
			}
			for _, id := range tc.items {
				e := progressionEvent(PlayerProxy{ID: 123, CharLevel: 2})
				e.Trade = &TradeProxy{Items: []int{id, 13005}}
				capture, err := NewLuaBridge("upstream/projecteq").ExecuteTradeFromSource(source, e)
				require.NoError(t, err, "route %d", id)
				require.ElementsMatch(t, []int{13005}, capture.CurrentTrade.Items, "route %d", id)
				require.EqualValues(t, 1550, capture.Exp, "route %d", id)
				require.Positive(t, capture.Currency.Gold, "route %d", id)
			}
			e := progressionEvent(PlayerProxy{ID: 123, CharLevel: 2})
			e.Trade = &TradeProxy{Items: append(append([]int{}, tc.items...), 13005)}
			capture, err := NewLuaBridge("upstream/projecteq").ExecuteTradeFromSource(source, e)
			require.NoError(t, err)
			require.EqualValues(t, 1550, capture.Exp)
			require.Len(t, capture.CurrentTrade.Items, len(tc.items))
			require.Contains(t, capture.CurrentTrade.Items, 13005)
		})
	}
}

// Identical-looking scrolls are alternatives at Edvard, but a complete set at
// Umvera. Keep that distinction in the quest data, not a global AND-to-OR rule.
func TestScrollAlternativesAndCompleteSetRemainDistinct(t *testing.T) {
	items := []int{18504, 18505, 18506, 18507}
	for _, tc := range []struct {
		name, source string
		individual   bool
	}{
		{"Edvard", readOverrideLua(t, "modified-upstream", "qeynos", "Edvard_Tommels"), true},
		{"Umvera", readUpstreamLua(t, "qeynos", "Umvera_Dekash"), false},
	} {
		t.Run(tc.name, func(t *testing.T) {
			for _, id := range items {
				e := progressionEvent(PlayerProxy{ID: 123, CharLevel: 30})
				e.Trade = &TradeProxy{Items: []int{id}}
				capture, err := NewLuaBridge("upstream/projecteq").ExecuteTradeFromSource(tc.source, e)
				require.NoError(t, err)
				if tc.individual {
					require.Empty(t, capture.CurrentTrade.Items)
					require.Positive(t, capture.Exp)
				} else {
					require.Equal(t, []int{id}, capture.CurrentTrade.Items)
					require.Zero(t, capture.Exp)
				}
			}
			e := progressionEvent(PlayerProxy{ID: 123, CharLevel: 30})
			e.Trade = &TradeProxy{Items: append([]int{}, items...)}
			capture, err := NewLuaBridge("upstream/projecteq").ExecuteTradeFromSource(tc.source, e)
			require.NoError(t, err)
			require.Empty(t, capture.CurrentTrade.Items)
			require.Positive(t, capture.Exp)
			require.NotEmpty(t, capture.Items)
		})
	}
}

func TestLorkReturnsIncompleteHeartSets(t *testing.T) {
	source := readConvertedPerlLua(t, "oggok", "Lork")
	for _, tc := range []struct {
		name             string
		items, remaining []int
		complete         bool
	}{
		{"Kryn alone", []int{13227}, []int{13227}, false},
		{"Dvinn alone", []int{13358}, []int{13358}, false},
		{"heart after unrelated item", []int{13005, 13227}, []int{13005, 13227}, false},
		{"duplicate is not the other heart", []int{13227, 13227}, []int{13227, 13227}, false},
		{"both hearts", []int{13227, 13358}, nil, true},
		{"both and unrelated", []int{13358, 13005, 13227}, []int{13005}, true},
	} {
		t.Run(tc.name, func(t *testing.T) {
			e := progressionEvent(PlayerProxy{ID: 123, CharLevel: 30})
			e.Trade = &TradeProxy{Items: tc.items}
			capture, err := NewLuaBridge("upstream/projecteq").ExecuteTradeFromSource(source, e)
			require.NoError(t, err)
			require.ElementsMatch(t, tc.remaining, capture.CurrentTrade.Items)
			if tc.complete {
				require.EqualValues(t, 100, capture.Exp)
				require.Len(t, capture.Items, 1)
			} else {
				require.Zero(t, capture.Exp)
				require.Empty(t, capture.Items, "return original trade instances, not replacement items")
				require.Empty(t, capture.Factions)
			}
		})
	}
}
