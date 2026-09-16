package quest

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestNatashaMessagePreservesNPCButRingDepops(t *testing.T) {
	source := readOverrideLua(t, "modified-upstream", "timorous", "Natasha_Whitewater")
	for _, tc := range []struct {
		item, reward int
		depops       bool
	}{
		{28052, 28054, false}, {28018, 28056, true},
	} {
		event := progressionEvent(PlayerProxy{ID: 123, Name: "Cleric"})
		event.SpawnInstanceID = 5001
		event.Trade = &TradeProxy{Items: []int{tc.item, 1001}}
		capture, err := NewLuaBridge("upstream/projecteq").ExecuteTradeFromSource(source, event)
		require.NoError(t, err)
		require.Equal(t, []QuestReward{{ItemID: tc.reward, Count: 1}}, capture.Items)
		require.Equal(t, []int{1001}, capture.CurrentTrade.Items)
		require.Equal(t, tc.depops, len(capture.Depops) > 0)
	}
}

func TestClericHostileSpawnsAttackOnlyTheirOwner(t *testing.T) {
	for _, tc := range []struct {
		origin, zone, name string
		id                 int32
		attacks            bool
	}{
		{"idlequest-authored", "soltemple", "a_plasmatic_priest", 80042, true},
		{"modified-upstream", "soldungb", "Zordak_Ragefire", 91096, true},
		{"modified-upstream", "soldungb", "Zordak_Ragefire", 32038, false},
		{"idlequest-authored", "soldungb", "Zordakalicus_Ragefire", 91090, true},
	} {
		t.Run(tc.zone+"/"+tc.name, func(t *testing.T) {
			event := progressionEvent(PlayerProxy{ID: 123, Name: "Cleric"})
			event.NPC.ID = tc.id
			bridge := NewLuaBridge("upstream/projecteq")
			bridge.RequireImplementedEffects = true
			capture, err := bridge.ExecuteEventFromSource(
				readOverrideLua(t, tc.origin, tc.zone, tc.name), "event_spawn", event)
			require.NoError(t, err)
			if tc.attacks {
				require.Equal(t, []QuestAttackRequest{{PlayerName: "Cleric"}}, capture.Attacks)
			} else {
				require.Empty(t, capture.Attacks)
			}
			require.Empty(t, capture.DeferredAPIs)
		})
	}
}
