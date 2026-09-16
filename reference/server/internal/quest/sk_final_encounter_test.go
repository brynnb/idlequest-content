package quest

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestP99LhrancHandinReleasesEncounterWithoutTokenOrFreeSword(t *testing.T) {
	bridge := NewLuaBridge("upstream/projecteq")
	bridge.RequireImplementedEffects = true
	source := readOverrideLua(t, "modified-upstream", "citymist", "Lhranc")
	for _, complete := range []bool{false, true} {
		event := progressionEvent(PlayerProxy{Name: "Knight", Factions: map[int]int{404: -2000}})
		event.NPC.ID = 90221
		event.Trade = &TradeProxy{Items: []int{14367, 14368, 14369, 1001}}
		if complete {
			// The real Give window has four item slots; do not invent a fifth.
			event.Trade.Items = []int{14367, 14368, 14369, 14370}
		}
		capture, err := bridge.ExecuteTradeFromSource(source, event)
		require.NoError(t, err)
		require.Empty(t, capture.Items, "neither token nor sword may be granted before the fight")
		require.Empty(t, capture.DeferredAPIs)
		if complete {
			require.Empty(t, capture.CurrentTrade.Items)
			require.Len(t, capture.Spawns, 1)
			require.Equal(t, int32(90187), capture.Spawns[0].NPCTypeID)
			require.Len(t, capture.Depops, 1)
		} else {
			require.Equal(t, []int{14367, 14368, 14369, 1001}, capture.CurrentTrade.Items)
			require.Empty(t, capture.Spawns)
			require.Empty(t, capture.Depops)
		}
	}
}

func TestP99HumanLhrancAttacksOwnerWithoutRevampTimerOrMarl(t *testing.T) {
	bridge := NewLuaBridge(".")
	bridge.RequireImplementedEffects = true
	source := readOverrideLua(t, "modified-upstream", "citymist", "#Lhranc")
	event := progressionEvent(PlayerProxy{Name: "Knight"})
	event.NPC.ID = 90187
	capture, err := bridge.ExecuteEventFromSource(source, "event_spawn", event)
	require.NoError(t, err)
	require.Equal(t, []QuestAttackRequest{{PlayerName: "Knight"}}, capture.Attacks)
	require.Empty(t, capture.Timers)
	capture, err = bridge.ExecuteEventFromSource(source, "event_death_complete", event)
	require.NoError(t, err)
	require.Empty(t, capture.Spawns, "P99 sword is on the corpse; no later-era Marl spawn")
	require.Empty(t, capture.Items)
}

// The preserved P99 page explicitly corrects its older charging-mummy account:
// players fight the mummy in the crypt. Do not add forced aggro to this trade.
func TestP99GlohnorRequiresShroudAndSpawnsMummyWithoutGrantingDrops(t *testing.T) {
	bridge := NewLuaBridge("upstream/projecteq")
	bridge.RequireImplementedEffects = true
	source := readOverrideLua(t, "converted-perl", "hole", "#Ghost_of_Glohnor")
	for _, item := range []int{1001, 14377} {
		event := progressionEvent(PlayerProxy{Name: "Knight", Factions: map[int]int{404: -2000}})
		event.NPC.ID = 39082
		event.Trade = &TradeProxy{Items: []int{item}}
		capture, err := bridge.ExecuteTradeFromSource(source, event)
		require.NoError(t, err)
		require.Empty(t, capture.Items, "Head and wrappings must come from the actual corpse")
		require.Empty(t, capture.Attacks)
		require.Empty(t, capture.DeferredAPIs)
		if item == 14377 {
			require.Empty(t, capture.CurrentTrade.Items)
			require.Len(t, capture.Spawns, 1)
			require.Equal(t, int32(39165), capture.Spawns[0].NPCTypeID)
			require.Len(t, capture.Depops, 1)
		} else {
			require.Equal(t, []int{item}, capture.CurrentTrade.Items)
			require.Empty(t, capture.Spawns)
			require.Empty(t, capture.Depops)
		}
	}
}
