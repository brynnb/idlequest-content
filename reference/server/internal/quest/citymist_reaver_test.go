package quest

import (
	"fmt"
	"github.com/stretchr/testify/require"
	"idlequest/internal/quest/overrides"
	"testing"
)

// Exercise the canonical bundled source, including every random branch, rather
// than testing a hand-copied script for an NPC absent from the active zone.
func TestCitymistVersionZeroReaverCycles(t *testing.T) {
	scripts, err := overrides.Scripts()
	require.NoError(t, err)
	sources := map[string]string{}
	for _, script := range scripts {
		if script.Zone == "citymist" {
			sources[script.Name] = script.Lua
		}
	}
	for _, tc := range []struct {
		id      int
		endings []int32
		unique  bool
	}{
		{90000, []int32{90184}, false}, {90010, []int32{90174}, true},
		{90012, []int32{90180}, true}, {90199, []int32{90210, 90211, 90201, 90203, 90218, 90219}, false},
	} {
		t.Run(fmt.Sprint(tc.id), func(t *testing.T) {
			source := sources[fmt.Sprint(tc.id)]
			require.NotEmpty(t, source)
			for _, roll := range []int{1, 80, 81, 100} {
				for _, ending := range tc.endings {
					// Control only randomness; use the real Lua dispatch and spawn capture.
					controlled := source + fmt.Sprintf("\nmath.random = function(n) return %d end\neq.ChooseRandom = function(...) return %d end\n", roll, ending)
					capture, err := NewLuaBridge(".").ExecuteEventFromSource(controlled, "event_death_complete", &LuaEvent{
						NPC:    &NPCProxy{ID: int32(tc.id), Name: "a_black_reaver", X: 186, Y: 144, Z: 294, Heading: 32},
						Player: &PlayerProxy{ID: 77, Name: "Tester"}, SpawnInstanceID: 3265703,
					})
					require.NoError(t, err)
					require.Len(t, capture.Spawns, 1)
					want := ending
					unique := tc.unique
					if roll <= 80 {
						want = int32(tc.id)
						unique = false
					}
					require.Equal(t, QuestSpawnRequest{NPCTypeID: want, X: 186, Y: 144, Z: 294, Heading: 32, Unique: unique}, capture.Spawns[0])
				}
			}
		})
	}
}
