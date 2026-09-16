package quest

import (
	"fmt"
	"os"
	"testing"

	"github.com/stretchr/testify/require"
)

// Exercise the actual source separately from the source-only runtime matrix.
// Resolving Iceberg does not implement following: strict execution must still
// reject that deferred effect, not declare this interaction playable.
func TestTundraJackSignalResolvesIcebergButStillRequiresFollowing(t *testing.T) {
	source, err := os.ReadFile("upstream/projecteq/everfrost/Tundra_Jack.lua")
	require.NoError(t, err)
	for _, strict := range []bool{false, true} {
		t.Run(fmt.Sprintf("strict=%t", strict), func(t *testing.T) {
			bridge := NewLuaBridge(".")
			bridge.RequireImplementedEffects = strict
			lookups := 0
			event := &LuaEvent{
				NPC:             &NPCProxy{ID: 30069, Name: "Tundra_Jack"},
				SpawnInstanceID: 6001,
				Fields:          map[string]any{"signal": 1},
				ResolveNPC: func(query QuestNPCQuery) (*NPCProxy, error) {
					lookups++
					require.Equal(t, QuestNPCQuery{NPCTypeID: 30062}, query)
					return &NPCProxy{ID: 30062, Name: "Iceberg", SpawnInstanceID: 6002}, nil
				},
			}
			capture, executeErr := bridge.ExecuteEventFromSource(string(source), "event_signal", event)
			require.Equal(t, 1, lookups)
			if strict {
				require.ErrorContains(t, executeErr, "quest runtime capability not implemented: eq.follow")
				require.Nil(t, capture)
			} else {
				require.NoError(t, executeErr)
				require.Equal(t, []string{"On my way, Iceberg!!"}, capture.Responses)
				require.Equal(t, []string{"eq.follow"}, capture.DeferredAPIs)
			}
		})
	}
}
