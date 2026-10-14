package quest

import (
	"fmt"

	lua "github.com/yuin/gopher-lua"
)

// The world supplies this resolver from an owner/zone/instance-scoped live
// population. EQEmu GetNPCBySpawnID matches GetSpawnGroupId (entity.cpp),
// not the spawn2 placement or transient entity ID.
type QuestNPCQuery struct {
	NPCTypeID    int32
	SpawnGroupID int64
}

type QuestNPCResolver func(QuestNPCQuery) (*NPCProxy, error)
type QuestNPCEnumerator func() ([]NPCProxy, error)

func npcEnumeratorFromFields(fields map[string]any) QuestNPCEnumerator {
	list, _ := fields["__quest_npc_enumerator"].(QuestNPCEnumerator)
	return list
}

// Snapshot once per iterator; never expose mutable population-owned proxies.
// Both list.entries and GetNPCEntries use the same identity/effect boundary.
func (b *LuaBridge) npcEntries(L *lua.LState, event *LuaEvent, capture *QuestCapture, api string, asList bool) int {
	if event.ListNPCs == nil {
		return capture.recordDeferredAPI(L, api)
	}
	actors, err := event.ListNPCs()
	if err != nil {
		return capture.rejectActorEffect(L, fmt.Sprintf("enumerate quest NPCs: %v", err))
	}
	actors = append([]NPCProxy(nil), actors...)
	seen := make(map[int64]bool, len(actors))
	for _, actor := range actors {
		if actor.ID <= 0 || actor.SpawnInstanceID <= 0 || seen[actor.SpawnInstanceID] {
			return capture.rejectActorEffect(L, "NPC enumeration returned invalid or duplicate identity")
		}
		seen[actor.SpawnInstanceID] = true
	}
	index := 0
	iterator := L.NewFunction(func(L *lua.LState) int {
		if index >= len(actors) {
			L.Push(lua.LNil)
			return 1
		}
		b.pushResolvedNPC(L, event, capture, actors[index])
		index++
		return 1
	})
	if asList {
		list := L.NewTable()
		L.SetField(list, "entries", iterator)
		L.Push(list)
	} else {
		L.Push(iterator)
	}
	return 1
}

func npcResolverFromFields(fields map[string]any) QuestNPCResolver {
	resolver, _ := fields["__quest_npc_resolver"].(QuestNPCResolver)
	return resolver
}

func (b *LuaBridge) npcLookup(L *lua.LState, event *LuaEvent, capture *QuestCapture, api string, placement bool) int {
	if event.ResolveNPC == nil {
		return capture.recordDeferredAPI(L, api)
	}
	value := L.CheckNumber(2)
	id := int64(value)
	if id <= 0 || value != lua.LNumber(id) || value > 9007199254740991 || (!placement && id > 2147483647) {
		return capture.rejectActorEffect(L, "invalid NPC lookup identity")
	}
	query := QuestNPCQuery{NPCTypeID: int32(id)}
	if placement {
		query = QuestNPCQuery{SpawnGroupID: id}
	}
	actor, err := event.ResolveNPC(query)
	if err != nil {
		return capture.rejectActorEffect(L, fmt.Sprintf("resolve quest NPC: %v", err))
	}
	if actor == nil {
		// EQEmu returns a null Lua_NPC/Lua_Mob wrapper. Existing scripts use
		// target.valid/target.null before calling methods, not a nil comparison.
		ud := L.NewUserData()
		ud.Value = &NPCProxy{Capture: capture, externalActor: true, missingActor: true}
		L.SetMetatable(ud, b.createNPCMetatable(L))
		L.Push(ud)
		return 1
	}
	if actor.ID <= 0 || actor.SpawnInstanceID <= 0 || (!placement && actor.ID != query.NPCTypeID) {
		return capture.rejectActorEffect(L, "NPC resolver returned a mismatched actor")
	}
	b.pushResolvedNPC(L, event, capture, *actor)
	return 1
}

func (b *LuaBridge) pushResolvedNPC(L *lua.LState, event *LuaEvent, capture *QuestCapture, proxy NPCProxy) {
	proxy.Capture = capture
	proxy.readCombatActor = event.ReadNPCCombat
	proxy.readGrid = event.ReadNPCGrid
	if event.Player != nil {
		proxy.combatOwnerCharacterID = int64(event.Player.ID)
		proxy.combatOwner = event.Player
	}
	proxy.externalActor = event.NPC == nil || proxy.ID != event.NPC.ID || proxy.SpawnInstanceID != event.SpawnInstanceID
	capture.registerSpellActor(proxy.SpawnInstanceID, proxy.spellActor())
	ud := L.NewUserData()
	ud.Value = &proxy
	L.SetMetatable(ud, b.createNPCMetatable(L))
	L.Push(ud)
}

func (capture *QuestCapture) rejectActorEffect(L *lua.LState, reason string) int {
	capture.actorEffectError = fmt.Errorf("quest actor effect unavailable: %s", reason)
	L.RaiseError("%s", capture.actorEffectError)
	return 0
}

// These methods already carry concrete identity or only read the resolved
// actor. Other methods must not write into the event actor's ScriptState or
// emit type-wide mutations. Expand this boundary as delivery is implemented.
func supportsExternalNPCMethod(method string) bool {
	switch method {
	case "GetID", "GetNPCTypeID", "GetName", "GetCleanName", "GetX", "GetY", "GetZ", "GetHeading",
		"GetRace", "GetBaseRace", "GetGender", "GetClass",
		"Say", "Emote", "Shout", "AddToHateList", "GetHPRatio", "Signal", "Depop", "AddItem", "CastToNPC", "IsNPC", "IsMob", "GetTarget", "GetHateTop", "GetHateRandom", "IsEngaged", "IsCombatReserved", "GetGrid":
		return true
	}
	return false
}
