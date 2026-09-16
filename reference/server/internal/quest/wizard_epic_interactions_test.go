package quest

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestWizardKandinPostRevampDoesNotRequireOptionalNote(t *testing.T) {
	source := readOverrideLua(t, "modified-upstream", "butcher", "Kandin_Firepot")
	bridge := NewLuaBridge("upstream/projecteq")
	for _, withNote := range []bool{false, true} {
		event := progressionEvent(PlayerProxy{ID: 123, Name: "Wizard", CharClass: "Wizard", CharLevel: 50})
		if withNote {
			event.Globals["wizepicK"] = "1"
		}
		event.Message = "what oil"
		capture, err := bridge.ExecuteSayFromSource(source, event)
		require.NoError(t, err)
		require.Equal(t, []QuestReward{{ItemID: 14319, Count: 1}}, capture.Items)
		event.Trade = &TradeProxy{Items: []int{14349}}
		capture, err = bridge.ExecuteTradeFromSource(source, event)
		require.NoError(t, err)
		require.ElementsMatch(t, []QuestReward{{ItemID: 14339, Count: 1}, {ItemID: 18168, Count: 1}}, capture.Items)
	}
}

func TestWizardArantirInactivityTimerRefreshesOnConversation(t *testing.T) {
	source := readOverrideLua(t, "modified-upstream", "halas", "Arantir_Karondor")
	bridge := NewLuaBridge("upstream/projecteq")
	event := progressionEvent(PlayerProxy{ID: 123, Name: "Wizard", CharClass: "Wizard", CharLevel: 50})
	event.NPC.ID = 29089
	event.SpawnInstanceID = 6001
	for _, handler := range []string{"event_spawn", "event_say"} {
		event.Message = "story"
		capture, err := bridge.ExecuteEventFromSource(source, handler, event)
		require.NoError(t, err)
		require.Len(t, capture.Timers, 1)
		require.Equal(t, "ArantirDepop", capture.Timers[0].Name)
		require.EqualValues(t, 180000, capture.Timers[0].Interval)
		require.Empty(t, capture.Depops)
	}
	event.Fields = map[string]any{"timer": "unrelated"}
	capture, err := bridge.ExecuteEventFromSource(source, "event_timer", event)
	require.NoError(t, err)
	require.Empty(t, capture.Depops)
	event.Fields["timer"] = "ArantirDepop"
	capture, err = bridge.ExecuteEventFromSource(source, "event_timer", event)
	require.NoError(t, err)
	require.Len(t, capture.Depops, 1)
	require.EqualValues(t, 6001, capture.Depops[0].SpawnInstanceID)
}
