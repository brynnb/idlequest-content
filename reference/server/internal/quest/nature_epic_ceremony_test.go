package quest

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestNatureEpicCeremonySignalsAndAttack(t *testing.T) {
	bridge := NewLuaBridge("upstream/projecteq")
	event := progressionEvent(PlayerProxy{ID: 123, Name: "QuestOwner", CharClass: "Ranger", CharLevel: 50})
	event.NPC.ID = 15044
	event.SpawnInstanceID = 6001
	event.Fields = map[string]any{"signal": 1}
	source := readOverrideLua(t, "converted-perl", "eastkarana", "Althele")
	capture, err := bridge.ExecuteEventFromSource(source, "event_signal", event)
	require.NoError(t, err)
	require.Len(t, capture.Timers, 3)
	for i, delay := range []int{90000, 120000, 600000} {
		require.EqualValues(t, delay, capture.Timers[i].Interval)
	}
	require.Empty(t, capture.Spawns, "hand-in starts preparation, not immediate attackers")
	event.Fields = map[string]any{"timer": "prep"}
	capture, err = bridge.ExecuteEventFromSource(source, "event_timer", event)
	require.NoError(t, err)
	require.Contains(t, strings.Join(capture.Responses, " "), "Heed our call")
	require.Len(t, capture.Signals, 4)
	for i, id := range []int{15178, 15167, 15170, 15043} {
		require.Equal(t, id, capture.Signals[i].NPCID)
		require.Equal(t, 99, capture.Signals[i].SignalID)
		require.EqualValues(t, (i+1)*3000, capture.Signals[i].DelayMS)
	}
	event.Fields = map[string]any{"timer": "attack"}
	capture, err = bridge.ExecuteEventFromSource(source, "event_timer", event)
	require.NoError(t, err)
	require.Len(t, capture.Spawns, 3)
	require.EqualValues(t, 15153, capture.Spawns[0].NPCTypeID)
	require.EqualValues(t, 15150, capture.Spawns[1].NPCTypeID)
	require.EqualValues(t, 15150, capture.Spawns[2].NPCTypeID)
	require.Empty(t, capture.HateChanges, "intentional player-fought encounter; no NPC opponent requirement")
}

func TestNatureEpicTomeClosesTheCircle(t *testing.T) {
	event := progressionEvent(PlayerProxy{ID: 123, Name: "QuestOwner"})
	event.NPC.ID = 15044
	event.SpawnInstanceID = 6001
	event.Trade = &TradeProxy{Items: []int{20452}}
	capture, err := NewLuaBridge("upstream/projecteq").ExecuteTradeFromSource(readOverrideLua(t, "converted-perl", "eastkarana", "Althele"), event)
	require.NoError(t, err)
	require.Empty(t, capture.CurrentTrade.Items)
	require.Len(t, capture.Depops, 6)
	for i, id := range []int32{15178, 15167, 15170, 15043, 15042} {
		require.Equal(t, id, capture.Depops[i].NPCTypeID)
	}
	require.EqualValues(t, 6001, capture.Depops[5].SpawnInstanceID)
}

func TestNatureEpicGatheringUsesSameActors(t *testing.T) {
	for _, name := range []string{"Sionae", "Nuien", "Teloa"} {
		event := progressionEvent(PlayerProxy{ID: 123, Name: "QuestOwner"})
		event.SpawnInstanceID = 6001
		event.Fields = map[string]any{"signal": 1}
		source := readOverrideLua(t, "converted-perl", "eastkarana", name)
		capture, err := NewLuaBridge("upstream/projecteq").ExecuteEventFromSource(source, "event_signal", event)
		require.NoError(t, err)
		require.Len(t, capture.NPCMoves, 1, name)
		require.Empty(t, capture.Spawns, name)
		event.Fields["signal"] = 99
		capture, err = NewLuaBridge("upstream/projecteq").ExecuteEventFromSource(source, "event_signal", event)
		require.NoError(t, err)
		require.NotEmpty(t, capture.Responses, name)
		require.Empty(t, capture.NPCMoves, name)
	}
}
