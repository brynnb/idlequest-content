package quest

import (
	"github.com/stretchr/testify/require"
	"strings"
	"testing"
)

func TestShamanOoglynHandInStartsPatienceWithoutPatrol(t *testing.T) {
	bridge := NewLuaBridge("upstream/projecteq")
	event := progressionEvent(PlayerProxy{ID: 123, Name: "Shaman", CharClass: "Shaman", CharLevel: 50})
	event.NPC.ID = 98009
	event.SpawnInstanceID = 6001
	event.Trade = &TradeProxy{Items: []int{1666}}
	source := readOverrideLua(t, "modified-upstream", "erudsxing", "Ooglyn")
	capture, err := bridge.ExecuteTradeFromSource(source, event)
	require.NoError(t, err)
	require.Empty(t, capture.CurrentTrade.Items)
	require.Empty(t, capture.NPCMoves)
	require.Contains(t, strings.Join(capture.Responses, " "), "-1600, 4200")
	require.Len(t, capture.Timers, 1)
	require.EqualValues(t, 360000, capture.Timers[0].Interval)
	event.Fields = map[string]any{"timer": "depop"}
	capture, err = bridge.ExecuteEventFromSource(source, "event_timer", event)
	require.NoError(t, err)
	require.Len(t, capture.Spawns, 1)
	require.EqualValues(t, 98046, capture.Spawns[0].NPCTypeID)
	require.Equal(t, 4209.4, capture.Spawns[0].X)
	require.Equal(t, -1575.5, capture.Spawns[0].Y)
	require.NotEmpty(t, capture.Depops)
	event.Fields = map[string]any{"timer": "unrelated"}
	capture, err = bridge.ExecuteEventFromSource(source, "event_timer", event)
	require.NoError(t, err)
	require.Empty(t, capture.Spawns)
}

func TestShamanBondlGivesDestinationWithoutPatrol(t *testing.T) {
	event := progressionEvent(PlayerProxy{ID: 123, Name: "Shaman", CharClass: "Shaman"})
	event.Message = "you can buy booze"
	capture, err := NewLuaBridge("upstream/projecteq").ExecuteEventFromSource(readOverrideLua(t, "modified-upstream", "freportn", "Bondl_Felligan"), "event_say", event)
	require.NoError(t, err)
	require.Empty(t, capture.NPCMoves)
	require.Contains(t, strings.Join(capture.Responses, " "), "Jade Tiger Den")
}

func TestShamanPatienceDialogueKeywords(t *testing.T) {
	for _, tc := range []struct{ npc, message, response string }{
		{"Srafen_the_Soaked", "us", "there's me, Srafen"},
		{"Srafen_the_Soaked", "tell me about us", "there's me, Srafen"},
		{"Froham_the_Forgotten", "be ere soon", "trouble communicating"},
		{"Froham_the_Forgotten", "be here soon", "trouble communicating"},
	} {
		t.Run(tc.npc+"/"+tc.message, func(t *testing.T) {
			event := progressionEvent(PlayerProxy{ID: 123, Name: "Shaman", CharClass: "Shaman"})
			event.Message = tc.message
			capture, err := NewLuaBridge("upstream/projecteq").ExecuteEventFromSource(readOverrideLua(t, "modified-upstream", "erudsxing", tc.npc), "event_say", event)
			require.NoError(t, err)
			require.Contains(t, strings.Join(capture.Responses, " "), tc.response)
		})
	}
}

// Exercise the real Lua state carried between timer callbacks without camping
// through the complete optional ceremony. Scheduler/UI evidence is separate.
func TestShamanPatienceTimerSequenceWithoutPatrol(t *testing.T) {
	for _, tc := range []struct {
		name, timer     string
		interval, ticks int
		spawns          map[int]int32
	}{
		{"Srafen_the_Soaked", "DillonSpawn", 170000, 7, map[int]int32{1: 98051, 7: 98047}},
		{"Froham_the_Forgotten", "FrohamDepart", 330000, 2, map[int]int32{2: 98050}},
		{"Abe_the_Abandoned", "letbegin", 240000, 3, map[int]int32{3: 98052}},
	} {
		t.Run(tc.name, func(t *testing.T) {
			source := readOverrideLua(t, "modified-upstream", "erudsxing", tc.name)
			bridge := NewLuaBridge("upstream/projecteq")
			event := progressionEvent(PlayerProxy{ID: 123, Name: "Shaman", CharClass: "Shaman"})
			event.SpawnInstanceID = 6001
			capture, err := bridge.ExecuteEventFromSource(source, "event_spawn", event)
			require.NoError(t, err)
			require.Len(t, capture.Timers, 1)
			require.EqualValues(t, tc.interval, capture.Timers[0].Interval)
			for tick := 1; tick <= tc.ticks; tick++ {
				event.ScriptState = capture.ScriptState
				event.Fields = map[string]any{"timer": tc.timer}
				capture, err = bridge.ExecuteEventFromSource(source, "event_timer", event)
				require.NoError(t, err)
				require.Empty(t, capture.NPCMoves)
				if id, ok := tc.spawns[tick]; ok {
					require.Len(t, capture.Spawns, 1)
					require.EqualValues(t, id, capture.Spawns[0].NPCTypeID)
				} else {
					require.Empty(t, capture.Spawns)
				}
				if tick == tc.ticks {
					require.NotEmpty(t, capture.Depops)
				} else {
					require.Empty(t, capture.Depops)
				}
			}
		})
	}
}
