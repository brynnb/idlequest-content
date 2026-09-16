package quest

import (
	"github.com/stretchr/testify/require"
	"os"
	"testing"
)

func TestProximitySpeechSwitchCaptureAndIsolation(t *testing.T) {
	bridge := NewLuaBridge(".")
	bridge.RequireImplementedEffects = true
	event := progressionEvent(PlayerProxy{Name: "Listener"})
	for _, tc := range []struct {
		source  string
		enabled bool
	}{
		{`function event_say(e) eq.enable_proximity_say() end`, true},
		{`function event_say(e) eq.disable_proximity_say() end`, false},
		{`function event_say(e) eq.enable_proximity_say(); eq.disable_proximity_say() end`, false},
	} {
		capture, err := bridge.ExecuteEventFromSource(tc.source, "event_say", event)
		require.NoError(t, err)
		require.NotNil(t, capture.ProximitySayEnabled)
		require.Equal(t, tc.enabled, *capture.ProximitySayEnabled)
		clearQuestCaptureEffects(capture)
		require.Nil(t, capture.ProximitySayEnabled, "Preview/reset must discard listener changes")
	}
	_, err := bridge.ExecuteEventFromSource(`function event_say(e) eq.enable_proximity_say() end`, "event_trade", event)
	require.NoError(t, err)
}

func TestProximitySpeechSwitchSurvivesRuntimeEffectFilterAndMerge(t *testing.T) {
	destination := NewQuestCapture()
	for _, enabled := range []bool{true, false} {
		source := NewQuestCapture()
		source.ProximitySayEnabled = &enabled
		require.True(t, captureHasRuntimeEffects(source))
		require.True(t, captureHasEffects(source), "Registered encounter switch-only handlers must not be discarded")
		mergeQuestCapture(destination, source)
		require.Equal(t, enabled, *destination.ProximitySayEnabled)
	}
	mergeQuestCapture(destination, NewQuestCapture())
	require.False(t, *destination.ProximitySayEnabled, "Absent update must preserve explicit disable")
}

func TestGarzicorActualPhraseAndTimedGroundItems(t *testing.T) {
	source, err := os.ReadFile("upstream/projecteq/necropolis/123192.lua")
	require.NoError(t, err)
	bridge := NewLuaBridge(".")
	bridge.RequireImplementedEffects = true
	event := progressionEvent(PlayerProxy{Name: "Listener"})
	event.NPC.ID, event.NPC.X, event.NPC.Y, event.NPC.Z = 123192, 1109, 1523, -136
	invoke := func(handler string) *QuestCapture {
		capture, err := bridge.ExecuteEventFromSource(string(source), handler, event)
		require.NoError(t, err)
		event.ScriptState = capture.ScriptState
		return capture
	}
	invoke("event_spawn")
	event.Fields = map[string]any{"timer": "proxsay"}
	registered := invoke("event_timer")
	require.NotNil(t, registered.Proximity)
	require.NotNil(t, registered.ProximitySayEnabled)
	require.True(t, *registered.ProximitySayEnabled)
	event.Message = "Remember, Garzicor"
	event.Fields = nil
	started := invoke("event_proximity_say")
	require.NotNil(t, started.ProximitySayEnabled)
	require.False(t, *started.ProximitySayEnabled)
	require.Empty(t, started.GroundItems)
	event.Fields = map[string]any{"timer": "pause"}
	invoke("event_timer")
	event.Fields = map[string]any{"timer": "help"}
	for i := 1; i <= 14; i++ {
		capture := invoke("event_timer")
		if i < 14 {
			require.Empty(t, capture.GroundItems)
			continue
		}
		require.Len(t, capture.GroundItems, 2)
		require.ElementsMatch(t, []int32{1888, 1889}, []int32{capture.GroundItems[0].ItemID, capture.GroundItems[1].ItemID})
		require.Len(t, capture.Depops, 1)
	}
}
