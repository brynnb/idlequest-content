package quest

import (
	"os"
	"testing"

	"github.com/stretchr/testify/require"
)

// Executes the real script callbacks without sleeping for their content timers.
// This verifies Lua lifecycle intent; scheduler/world delivery has separate
// tests and must not be advertised as a rendered expiry from this test alone.
func TestEpicDepartureTimerCallbacks(t *testing.T) {
	for _, tc := range []struct {
		path         string
		interval     int
		combatPauses bool
	}{
		{"overrides/lua/modified-upstream/trakanon/#Kaiaren.lua", 3600000, false},
		{"upstream/projecteq/kaesora/enraged_spectral_librarian.lua", 300000, true},
		{"upstream/projecteq/airplane/Dirkog_Steelhand.lua", 300000, false},
		{"overrides/lua/modified-upstream/airplane/Inte_Akera.lua", 300000, false},
	} {
		t.Run(tc.path, func(t *testing.T) {
			source, err := os.ReadFile(tc.path)
			require.NoError(t, err)
			bridge := NewLuaBridge("upstream/projecteq")
			event := progressionEvent(PlayerProxy{ID: 123})
			spawn, err := bridge.ExecuteEventFromSource(string(source), "event_spawn", event)
			require.NoError(t, err)
			require.Equal(t, []TimerUpdate{{Name: "depop", Interval: tc.interval}}, spawn.Timers)
			event.Fields = map[string]any{"timer": "depop"}
			expiry, err := bridge.ExecuteEventFromSource(string(source), "event_timer", event)
			require.NoError(t, err)
			require.Len(t, expiry.Depops, 1)
			if tc.combatPauses {
				event.Fields = map[string]any{"joined": true}
				combat, err := bridge.ExecuteEventFromSource(string(source), "event_combat", event)
				require.NoError(t, err)
				require.Equal(t, []TimerUpdate{{Name: "depop", Stop: true}}, combat.Timers)
				event.Fields["joined"] = false
				idle, err := bridge.ExecuteEventFromSource(string(source), "event_combat", event)
				require.NoError(t, err)
				require.Equal(t, spawn.Timers, idle.Timers)
			}
		})
	}
}

func TestWilliaHailReplacesExpiryWithPleaAndEscapeTimers(t *testing.T) {
	source, err := os.ReadFile("upstream/projecteq/freportn/Guard_Willia.lua")
	require.NoError(t, err)
	bridge := NewLuaBridge("upstream/projecteq")
	event := progressionEvent(PlayerProxy{ID: 123})
	spawn, err := bridge.ExecuteEventFromSource(string(source), "event_spawn", event)
	require.NoError(t, err)
	require.Equal(t, []TimerUpdate{{Name: "depop", Interval: 1200000}}, spawn.Timers)
	event.Message = "hail"
	hail, err := bridge.ExecuteSayFromSource(string(source), event)
	require.NoError(t, err)
	require.Equal(t, []TimerUpdate{{Name: "depop", Stop: true}, {Name: "cry", Interval: 30000}}, hail.Timers)
	event.Fields = map[string]any{"timer": "cry"}
	cry, err := bridge.ExecuteEventFromSource(string(source), "event_timer", event)
	require.NoError(t, err)
	require.Equal(t, []TimerUpdate{{Name: "cry", Stop: true}, {Name: "run", Interval: 60000}}, cry.Timers)
	event.Fields["timer"] = "run"
	run, err := bridge.ExecuteEventFromSource(string(source), "event_timer", event)
	require.NoError(t, err)
	require.Contains(t, run.DeferredAPIs, "eq.start", "the escape is not implemented by timer capture")
	require.Len(t, run.NPCMoves, 2)
	require.Equal(t, QuestNPCMoveSetRunning, run.NPCMoves[0].Kind)
	require.True(t, run.NPCMoves[0].Running)
	require.Equal(t, QuestNPCMoveGridStart, run.NPCMoves[1].Kind)
	require.Equal(t, int32(14), run.NPCMoves[1].GridID)
}
