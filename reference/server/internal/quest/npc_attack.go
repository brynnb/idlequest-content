package quest

import (
	"fmt"
	"math"

	lua "github.com/yuin/gopher-lua"
)

// EQEmu QuestManager::attacknpctype resolves an NPC type, then adds hate=1.
// Use the same scoped resolver and concrete hate references as AddToHateList.
// Capture alone does not enable delivery: this API remains deferred until the
// world/client executor supports NPC defenders and normal death attribution.
func (b *LuaBridge) registerQuestNPCAttackAPI(L *lua.LState, eq *lua.LTable, capture *QuestCapture, event *LuaEvent) {
	L.SetField(eq, "attack_npc_type", L.NewFunction(func(L *lua.LState) int {
		capture.recordDeferredAPI(L, "eq.attack_npc_type")
		value, ok := L.Get(1).(lua.LNumber)
		id := float64(value)
		if L.GetTop() != 1 || !ok || math.IsNaN(id) || math.IsInf(id, 0) || id <= 0 || id > math.MaxInt32 || math.Trunc(id) != id {
			return capture.rejectActorEffect(L, "attack_npc_type requires a positive NPC type integer")
		}
		if event == nil || event.NPC == nil || event.NPC.ID <= 0 || event.SpawnInstanceID <= 0 || event.ResolveNPC == nil {
			return capture.rejectActorEffect(L, "attack_npc_type requires a concrete source and scoped NPC resolver")
		}
		target, err := event.ResolveNPC(QuestNPCQuery{NPCTypeID: int32(id)})
		if err != nil {
			return capture.rejectActorEffect(L, fmt.Sprintf("resolve attack NPC: %v", err))
		}
		if target == nil {
			capture.Responses = append(capture.Responses, fmt.Sprintf("I am unable to locate NPC type %d", int32(id)))
			return 0
		}
		if target.ID != int32(id) || target.SpawnInstanceID <= 0 || target.missingActor {
			return capture.rejectActorEffect(L, "attack_npc_type resolver returned a mismatched actor")
		}
		if target.SpawnInstanceID == event.SpawnInstanceID {
			return capture.rejectActorEffect(L, "attack_npc_type cannot attack its source")
		}
		capture.HateChanges = append(capture.HateChanges, QuestHateChange{
			Order:  capture.nextActorEffectOrder(),
			Source: QuestSpellActor{NPCTypeID: event.NPC.ID, SpawnInstanceID: event.SpawnInstanceID},
			Target: QuestSpellActor{NPCTypeID: target.ID, SpawnInstanceID: target.SpawnInstanceID},
			Hate:   1, YellForHelp: true,
		})
		return 0
	}))
}
