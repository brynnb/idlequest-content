package quest

import (
	"github.com/stretchr/testify/require"
	"testing"
)

func TestTimerOperationsPreserveScriptAndMergedCallbackOrder(t *testing.T) {
	bridge := NewLuaBridge(".")
	event := &LuaEvent{NPC: &NPCProxy{ID: 9001}, Player: &PlayerProxy{ID: 101}, SpawnInstanceID: 5001}
	first, err := bridge.ExecuteSayFromSource(`function event_say(e)
eq.set_timer("first", 60000)
eq.stop_all_timers()
eq.set_timer("second", 120000)
eq.pause_timer("second")
end`, event)
	require.NoError(t, err)
	second, err := bridge.ExecuteSayFromSource(`function event_say(e)
eq.resume_timer("second")
eq.stop_timer("second")
eq.set_timer("second", 180000)
end`, event)
	require.NoError(t, err)
	merged := NewQuestCapture()
	mergeQuestCapture(merged, first)
	mergeQuestCapture(merged, second)
	require.Equal(t, []TimerUpdate{
		{Name: "first", Interval: 60000}, {Name: "*", Stop: true},
		{Name: "second", Interval: 120000}, {Name: "second", Pause: true},
		{Name: "second", Resume: true}, {Name: "second", Stop: true},
		{Name: "second", Interval: 180000},
	}, merged.Timers)
}
