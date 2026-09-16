package quest

import (
	"math"

	lua "github.com/yuin/gopher-lua"
)

// References reuse the spell boundary's disjoint character/NPC/pending-spawn
// identity model. Never infer an actor namespace from a numeric Lua ID.
type QuestHateChange struct {
	Order       int
	Source      QuestSpellActor
	Target      QuestSpellActor
	Hate        int64
	Damage      int64
	YellForHelp bool
	Frenzy      bool
	BuffTick    bool
}

func (c *QuestCapture) nextActorEffectOrder() int {
	return len(c.HateChanges) + len(c.NPCMoves) + 1
}

func (n *NPCProxy) captureHateAddition(L *lua.LState) int {
	n.Capture.recordDeferredAPI(L, "e.self:AddToHateList")
	request := QuestHateChange{Order: n.Capture.nextActorEffectOrder(), Source: n.spellActor(), YellForHelp: true}
	if L.GetTop() < 2 || L.GetTop() > 7 {
		return n.Capture.rejectActorEffect(L, "AddToHateList requires an actor and at most five options")
	}
	ud, ok := L.Get(2).(*lua.LUserData)
	if !ok {
		return n.Capture.rejectActorEffect(L, "AddToHateList target must be a resolved actor")
	}
	switch target := ud.Value.(type) {
	case *PlayerProxy:
		if target.ID <= 0 {
			return n.Capture.rejectActorEffect(L, "AddToHateList player has no identity")
		}
		request.Target = QuestSpellActor{CharacterID: uint32(target.ID)}
	case *NPCProxy:
		if target.missingActor || target.ID <= 0 || (target.SpawnInstanceID <= 0 && target.PendingSpawnIndex <= 0) {
			return n.Capture.rejectActorEffect(L, "AddToHateList NPC has no concrete identity")
		}
		request.Target = target.spellActor()
	default:
		return n.Capture.rejectActorEffect(L, "AddToHateList target is not a combat actor")
	}
	// EQEmu mob.h defaults: hate=0, damage=0, yell=true, frenzy=false,
	// buff_tic=false. Retain flags rather than silently dropping semantics.
	for index, dest := range map[int]*int64{3: &request.Hate, 4: &request.Damage} {
		if L.GetTop() < index {
			continue
		}
		value, ok := L.Get(index).(lua.LNumber)
		if !ok || math.IsNaN(float64(value)) || math.IsInf(float64(value), 0) ||
			math.Trunc(float64(value)) != float64(value) || math.Abs(float64(value)) > 9007199254740991 {
			return n.Capture.rejectActorEffect(L, "AddToHateList amounts must be exact finite integers")
		}
		*dest = int64(value)
	}
	for index, dest := range map[int]*bool{5: &request.YellForHelp, 6: &request.Frenzy, 7: &request.BuffTick} {
		if L.GetTop() < index {
			continue
		}
		value, ok := L.Get(index).(lua.LBool)
		if !ok {
			return n.Capture.rejectActorEffect(L, "AddToHateList flags must be booleans")
		}
		*dest = bool(value)
	}
	n.Capture.HateChanges = append(n.Capture.HateChanges, request)
	return 0
}
