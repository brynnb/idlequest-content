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
)

// Exactly one actor, or neither for an observed empty selection. Failure to
// obtain a combat snapshot is an error, not an empty hate list or self target.
type QuestCombatActor struct {
	NPC    *NPCProxy
	Player *PlayerProxy
}

// The world reader owns scope, current ownership generation, and selection
// semantics. The Lua bridge never guesses a target from numeric ID overlap.
type QuestNPCCombatReader func(QuestSpellActor, QuestNPCCombatSelection) (QuestCombatActor, error)

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
	if actor.NPC != nil && actor.Player != nil {
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
