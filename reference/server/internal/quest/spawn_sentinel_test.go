package quest

import (
	"fmt"
	"github.com/stretchr/testify/require"
	"os"
	"testing"
)

func TestZeroSpawnReturnsNullWithoutConsumingPendingIdentity(t *testing.T) {
	for _, api := range []string{"spawn2", "unique_spawn"} {
		capture, err := NewLuaBridge(".").ExecuteEventFromSource(fmt.Sprintf(`function event_signal(e)
local absent = eq.%s(0,0,0,1,2,3,4)
assert(absent.null and not absent.valid and absent:GetID() == 0)
absent:Depop()
local next = eq.spawn2(72105,0,0,1,2,3,4)
next:AddItem(1001,1)
end`, api), "event_signal", &LuaEvent{NPC: &NPCProxy{ID: 72000}, Player: &PlayerProxy{}, SpawnInstanceID: 6001})
		require.NoError(t, err)
		require.Len(t, capture.Spawns, 1)
		require.Equal(t, int32(72105), capture.Spawns[0].NPCTypeID)
		require.Empty(t, capture.Depops)
	}
}

func TestFearGolemDeathSupportsBothRandomSpawnOutcomes(t *testing.T) {
	for _, name := range []string{"Dread", "Fright", "Terror"} {
		source, err := os.ReadFile("upstream/projecteq/fearplane/" + name + ".lua")
		require.NoError(t, err)
		for _, choice := range []int{0, 72105} {
			// Replace only the random chooser to exercise each real source branch.
			capture, err := NewLuaBridge(".").ExecuteEventFromSource(fmt.Sprintf("eq.ChooseRandom=function(...) return %d end\n", choice)+string(source), "event_death_complete", &LuaEvent{NPC: &NPCProxy{ID: 72000}, Player: &PlayerProxy{}, SpawnInstanceID: 6001})
			require.NoError(t, err)
			if choice == 0 {
				require.Empty(t, capture.Spawns)
			} else {
				require.Len(t, capture.Spawns, 1)
				require.Equal(t, int32(choice), capture.Spawns[0].NPCTypeID)
			}
		}
	}
}

func TestMalformedSpawnIdentityCannotMasqueradeAsZeroSentinel(t *testing.T) {
	for _, value := range []string{"-1", "0.5", "4294967296", "1/0", "0/0"} {
		capture, err := NewLuaBridge(".").ExecuteEventFromSource(`function event_signal(e)
pcall(function() eq.spawn2(`+value+`,0,0,1,2,3,4) end)
e.other:SummonItem(1001)
end`, "event_signal", &LuaEvent{NPC: &NPCProxy{}, Player: &PlayerProxy{}})
		require.ErrorContains(t, err, "invalid quest spawn NPC type identity")
		require.Nil(t, capture)
	}
}
