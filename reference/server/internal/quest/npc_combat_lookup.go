package quest

import (
	"fmt"

	lua "github.com/yuin/gopher-lua"
)

type QuestNPCCombatSelection string

const (
	QuestCombatCurrentTarget QuestNPCCombatSelection = "target"
	QuestCombatTopHate       QuestNPCCombatSelection = "top-hate"
	QuestCombatRandomHate    QuestNPCCombatSelection = "random-hate"
	QuestCombatEngagement    QuestNPCCombatSelection = "engaged"
	QuestCombatReservation   QuestNPCCombatSelection = "reserved"
)

// Actor selections return exactly one actor, or neither for observed emptiness.
// Engagement returns an explicit boolean independently of target selection:
// EQEmu Mob::IsEngaged tests hate-list membership, including pets/companions.
// Missing state is an error, never a fabricated empty hate list or self target.
type QuestNPCCombatResult struct {
	NPC     *NPCProxy
	Player  *PlayerProxy
	Engaged *bool
}

func (n *NPCProxy) IsEngaged(L *lua.LState) int {
	return n.readCombatBoolean(L, QuestCombatEngagement)
}

// IdleQuest admission state includes a newly reserved encounter whose first
// owner snapshot has not arrived yet. It must not masquerade as a hate lookup.
func (n *NPCProxy) IsCombatReserved(L *lua.LState) int {
	return n.readCombatBoolean(L, QuestCombatReservation)
}

func (n *NPCProxy) readCombatBoolean(L *lua.LState, selection QuestNPCCombatSelection) int {
	if n.readCombatActor == nil || n.SpawnInstanceID <= 0 || n.ID <= 0 || n.PendingSpawnIndex != 0 || n.missingActor {
		return n.Capture.rejectActorEffect(L, "NPC engagement requires a scoped reader and an existing concrete actor")
	}
	result, err := n.readCombatActor(n.spellActor(), selection)
	if err != nil {
		return n.Capture.rejectActorEffect(L, fmt.Sprintf("NPC engagement: %v", err))
	}
	if result.Engaged == nil || result.NPC != nil || result.Player != nil {
		return n.Capture.rejectActorEffect(L, "NPC engagement result is missing or ambiguous")
	}
	L.Push(lua.LBool(*result.Engaged))
	return 1
}

// The world reader owns scope, current ownership generation, and selection
// semantics. The Lua bridge never guesses a target from numeric ID overlap.
type QuestNPCCombatReader func(QuestSpellActor, QuestNPCCombatSelection) (QuestNPCCombatResult, error)

func npcCombatReaderFromFields(fields map[string]any) QuestNPCCombatReader {
	reader, _ := fields["__quest_npc_combat_reader"].(QuestNPCCombatReader)
	return reader
}

func (b *LuaBridge) pushNPCCombatActor(L *lua.LState, source *NPCProxy, selection QuestNPCCombatSelection) int {
	if source.readCombatActor == nil {
		return source.Capture.rejectActorEffect(L, "NPC combat lookup requires a scoped combat reader")
	}
	if source.SpawnInstanceID <= 0 || source.ID <= 0 || source.PendingSpawnIndex != 0 {
		return source.Capture.rejectActorEffect(L, "NPC combat lookup requires an existing concrete source")
	}
	actor, err := source.readCombatActor(source.spellActor(), selection)
	if err != nil {
		return source.Capture.rejectActorEffect(L, fmt.Sprintf("NPC combat lookup %s: %v", selection, err))
	}
	if actor.Engaged != nil || actor.NPC != nil && actor.Player != nil {
		return source.Capture.rejectActorEffect(L, "ambiguous NPC combat lookup result")
	}
	ud := L.NewUserData()
	if actor.Player != nil {
		// PlayerProxy reward methods address the event owner. Until those
		// writes have a separate cross-character authority, do not expose a
		// different character through a seemingly valid player wrapper.
		if actor.Player.ID <= 0 || int64(actor.Player.ID) != source.combatOwnerCharacterID {
			return source.Capture.rejectActorEffect(L, "combat player is not the quest owner")
		}
		player := *actor.Player
		if source.combatOwner != nil {
			player = *source.combatOwner
		}
		player.Capture = source.Capture
		source.Capture.registerSpellActor(int64(player.ID), QuestSpellActor{CharacterID: uint32(player.ID)})
		ud.Value = &player
		L.SetMetatable(ud, b.createPlayerMetatable(L))
	} else {
		npc := NPCProxy{Capture: source.Capture, missingActor: true, externalActor: true}
		if actor.NPC != nil {
			if actor.NPC.ID <= 0 || actor.NPC.SpawnInstanceID <= 0 || actor.NPC.PendingSpawnIndex != 0 {
				return source.Capture.rejectActorEffect(L, "invalid combat NPC identity")
			}
			npc = *actor.NPC
			npc.Capture = source.Capture
			npc.readCombatActor = source.readCombatActor
			npc.readGrid = source.readGrid
			npc.combatOwnerCharacterID = source.combatOwnerCharacterID
			npc.combatOwner = source.combatOwner
			npc.externalActor = npc.ID != source.ID || npc.SpawnInstanceID != source.SpawnInstanceID || source.externalActor
			source.Capture.registerSpellActor(npc.SpawnInstanceID, npc.spellActor())
		}
		ud.Value = &npc
		L.SetMetatable(ud, b.createNPCMetatable(L))
	}
	L.Push(ud)
	return 1
}
