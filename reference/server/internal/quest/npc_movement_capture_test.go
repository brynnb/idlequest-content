package quest

import (
	"github.com/stretchr/testify/require"
	"os"
	"testing"
)

func TestAltunicHouseDialogueRetainsOriginalWalkAndNarl(t *testing.T) {
	source, err := os.ReadFile("overrides/lua/converted-perl/ecommons/Altunic_Jartin.lua")
	require.NoError(t, err)
	capture, err := NewLuaBridge(".").ExecuteSayFromSource(string(source), &LuaEvent{
		NPC: &NPCProxy{ID: 22069}, Player: &PlayerProxy{ID: 123},
		SpawnInstanceID: 6001, Message: "Where is your house",
	})
	require.NoError(t, err)
	require.Len(t, capture.NPCMoves, 1)
	move := capture.NPCMoves[0]
	require.Equal(t, QuestNPCMoveWalk, move.Kind)
	require.Equal(t, int64(6001), move.SpawnInstanceID)
	require.Equal(t, 4791.06, move.X)
	require.Equal(t, -83.55, move.Y)
	require.Equal(t, -51.47, move.Z)
	require.Len(t, capture.Spawns, 1)
}

func TestGridControlPreservesOrderAndRejectsMalformedIDs(t *testing.T) {
	event := &LuaEvent{NPC: &NPCProxy{ID: 8110}, Player: &PlayerProxy{}, SpawnInstanceID: 6001}
	bridge := NewLuaBridge(".")
	capture, err := bridge.ExecuteEventFromSource(`function event_signal(e)
e.self:SetRunning(true); eq.start(14); eq.stop()
end`, "event_signal", event)
	require.NoError(t, err)
	require.Len(t, capture.NPCMoves, 3)
	for i, move := range capture.NPCMoves {
		require.Equal(t, i+1, move.Order)
		require.Equal(t, int64(6001), move.SpawnInstanceID)
		require.Equal(t, int32(8110), move.NPCTypeID)
	}
	require.Equal(t, int32(14), capture.NPCMoves[1].GridID)
	require.Equal(t, QuestNPCMoveGridStop, capture.NPCMoves[2].Kind)
	require.Contains(t, capture.DeferredAPIs, "eq.start")
	require.Contains(t, capture.DeferredAPIs, "eq.stop")
	for _, value := range []string{"0", "-1", "1.5", "1/0", "0/0", "2147483648", `"14"`} {
		t.Run(value, func(t *testing.T) {
			_, err := bridge.ExecuteEventFromSource(`function event_signal(e) pcall(function() eq.start(`+value+`) end) end`, "event_signal", event)
			require.ErrorContains(t, err, "grid ID must be a positive int32")
		})
	}
}

func TestNPCMovementCapturePreservesKindAndConcreteActor(t *testing.T) {
	event := &LuaEvent{NPC: &NPCProxy{ID: 9001, Heading: 4}, Player: &PlayerProxy{}, SpawnInstanceID: 6001}
	capture, err := NewLuaBridge(".").ExecuteEventFromSource(`function event_signal(e)
e.self:MoveTo(10,20,30)
e.self:GMMove(10,20,30)
e.self:SetRunning(false)
end`, "event_signal", event)
	require.NoError(t, err)
	require.Len(t, capture.NPCMoves, 3)
	require.Equal(t, QuestNPCMoveWalk, capture.NPCMoves[0].Kind)
	require.Equal(t, QuestNPCMoveTeleport, capture.NPCMoves[1].Kind)
	require.Equal(t, QuestNPCMoveSetRunning, capture.NPCMoves[2].Kind)
	for _, move := range capture.NPCMoves {
		require.Equal(t, int64(6001), move.SpawnInstanceID)
		require.Equal(t, int32(9001), move.NPCTypeID)
		require.Zero(t, move.PendingSpawnIndex)
	}
	require.False(t, capture.NPCMoves[2].Running)
	require.Equal(t, 4.0, capture.NPCMoves[0].Heading)
	require.False(t, capture.NPCMoves[0].SaveGuardSpot)
	require.Equal(t, 0.01, capture.NPCMoves[1].Heading)
	require.True(t, capture.NPCMoves[1].SaveGuardSpot)
	require.Len(t, capture.DeferredAPIs, 3, "capturing intent does not implement delivery")
}

func TestNPCGMMoveExplicitArgumentsOverrideTeleportDefaults(t *testing.T) {
	capture, err := NewLuaBridge(".").ExecuteEventFromSource(`function event_signal(e)
e.self:GMMove(10,20,30,42)
e.self:GMMove(10,20,30,0,false)
end`, "event_signal", &LuaEvent{NPC: &NPCProxy{ID: 9001, Heading: 7}, Player: &PlayerProxy{}, SpawnInstanceID: 6001})
	require.NoError(t, err)
	require.Len(t, capture.NPCMoves, 2)
	require.Equal(t, 42.0, capture.NPCMoves[0].Heading)
	require.True(t, capture.NPCMoves[0].SaveGuardSpot)
	require.Zero(t, capture.NPCMoves[1].Heading)
	require.False(t, capture.NPCMoves[1].SaveGuardSpot)
}

func TestNPCMovementCaptureRetainsPendingSpawnIdentity(t *testing.T) {
	capture, err := NewLuaBridge(".").ExecuteEventFromSource(`function event_signal(e)
local first = eq.spawn2(9002,0,0,1,2,3,4)
local second = eq.spawn2(9002,0,0,5,6,7,8)
first:MoveTo(11,12,13)
second:GMMove(21,22,23)
end`, "event_signal", &LuaEvent{NPC: &NPCProxy{ID: 9001}, Player: &PlayerProxy{}, SpawnInstanceID: 6001})
	require.NoError(t, err)
	require.Len(t, capture.NPCMoves, 2)
	for i, move := range capture.NPCMoves {
		require.Equal(t, i+1, move.PendingSpawnIndex)
		require.Equal(t, int32(9002), move.NPCTypeID)
		require.Zero(t, move.SpawnInstanceID)
	}
}

func TestNPCMovementRejectsNonfiniteDestinationEvenThroughPcall(t *testing.T) {
	capture, err := NewLuaBridge(".").ExecuteEventFromSource(`function event_signal(e)
pcall(function() e.self:MoveTo(1/0,2,3) end)
e.other:SummonItem(1001)
end`, "event_signal", &LuaEvent{NPC: &NPCProxy{ID: 9001}, Player: &PlayerProxy{}, SpawnInstanceID: 6001})
	require.ErrorContains(t, err, "coordinates must be finite")
	require.Nil(t, capture)
}
