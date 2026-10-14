package quest

import (
	lua "github.com/yuin/gopher-lua"
	"math"
)

// Preserve grid intent while the world executor remains guarded. EQEmu's
// lua_start accepts one grid ID; stop addresses the current event NPC.
func (b *LuaBridge) registerQuestGridAPIs(L *lua.LState, eq *lua.LTable, capture *QuestCapture, event *LuaEvent) {
	for _, api := range []string{"start", "stop"} {
		L.SetField(eq, api, L.NewFunction(func(L *lua.LState) int {
			capture.recordDeferredAPI(L, "eq."+api)
			if event == nil || event.NPC == nil || event.NPC.ID <= 0 {
				return capture.rejectActorEffect(L, "grid control requires an event NPC")
			}
			kind := QuestNPCMoveGridStop
			var gridID int32
			if api == "start" {
				value, ok := L.Get(1).(lua.LNumber)
				grid := float64(value)
				if !ok || math.IsNaN(grid) || math.IsInf(grid, 0) || grid <= 0 || grid > math.MaxInt32 || math.Trunc(grid) != grid {
					return capture.rejectActorEffect(L, "grid ID must be a positive int32")
				}
				gridID, kind = int32(grid), QuestNPCMoveGridStart
			}
			capture.NPCMoves = append(capture.NPCMoves, QuestNPCMoveRequest{
				Order: capture.nextActorEffectOrder(), Kind: kind, GridID: gridID,
				NPCTypeID: event.NPC.ID, SpawnInstanceID: event.SpawnInstanceID,
			})
			return 0
		}))
	}
}

func (n *NPCProxy) MoveTo(L *lua.LState) int {
	return n.captureMoveTo(L, "e.self:MoveTo", QuestNPCMoveWalk)
}

func (n *NPCProxy) captureMoveTo(L *lua.LState, api string, kind QuestNPCMoveKind) int {
	n.Capture.recordDeferredAPI(L, api)
	x := float64(L.CheckNumber(2))
	y := float64(L.CheckNumber(3))
	z := float64(L.CheckNumber(4))
	heading := n.Heading
	saveGuardSpot := false
	if kind == QuestNPCMoveTeleport {
		// EQEmu Mob::GMMove's omitted arguments are 0.01 and true
		// (zone/mob.h); teleport and routed MoveTo are not interchangeable.
		heading = 0.01
		saveGuardSpot = true
	}
	if L.GetTop() >= 5 && L.Get(5) != lua.LNil {
		heading = float64(L.CheckNumber(5))
	}
	for _, coordinate := range []float64{x, y, z, heading} {
		if math.IsNaN(coordinate) || math.IsInf(coordinate, 0) {
			return n.Capture.rejectActorEffect(L, "NPC movement coordinates must be finite")
		}
	}
	if L.GetTop() >= 6 && L.Get(6) != lua.LNil {
		saveGuardSpot = lua.LVAsBool(L.Get(6))
	}
	// A requested route is not an observed position. There is no world executor
	// yet, so neither Lua reads nor hand-in validation may treat it as arrival.
	n.Capture.NPCMoves = append(n.Capture.NPCMoves, QuestNPCMoveRequest{
		Order:             n.Capture.nextActorEffectOrder(),
		Kind:              kind,
		SpawnInstanceID:   n.SpawnInstanceID,
		PendingSpawnIndex: n.PendingSpawnIndex,
		NPCTypeID:         n.ID,
		X:                 x,
		Y:                 y,
		Z:                 z,
		Heading:           heading,
		SaveGuardSpot:     saveGuardSpot,
		Running:           n.Running,
	})
	return 0
}

func (n *NPCProxy) GMMove(L *lua.LState) int {
	return n.captureMoveTo(L, "e.self:GMMove", QuestNPCMoveTeleport)
}

func (n *NPCProxy) SetRunning(L *lua.LState) int {
	n.Capture.recordDeferredAPI(L, "e.self:SetRunning")
	running := true
	if L.GetTop() >= 2 {
		running = lua.LVAsBool(L.Get(2))
	}
	n.Running = running
	n.Capture.NPCMoves = append(n.Capture.NPCMoves, QuestNPCMoveRequest{Order: n.Capture.nextActorEffectOrder(), Kind: QuestNPCMoveSetRunning, NPCTypeID: n.ID, SpawnInstanceID: n.SpawnInstanceID, PendingSpawnIndex: n.PendingSpawnIndex, Running: running})
	return 0
}
