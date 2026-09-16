package quest

import "fmt"

func npcVitalsFromFields(fields map[string]any) *QuestNPCVitals {
	vitals, _ := fields["__quest_npc_vitals"].(*QuestNPCVitals)
	return vitals
}

func applyQuestEventVitals(event *LuaEvent) error {
	vitals := event.NPCVitals
	if vitals == nil {
		return nil // Source-only executions may supply NPCProxy state directly.
	}
	if event.NPC == nil || event.SelfIsPlayer || vitals.NPCTypeID != event.NPC.ID ||
		vitals.SpawnInstanceID <= 0 || vitals.SpawnInstanceID != event.SpawnInstanceID || vitals.MaxHP <= 0 {
		return fmt.Errorf("quest NPC vitals snapshot does not match the event actor or has invalid maximum HP")
	}
	// Never mutate a population-owned proxy when creating an isolated Lua view.
	npc := *event.NPC
	npc.HP, npc.MaxHP = vitals.HP, vitals.MaxHP
	event.NPC = &npc
	return nil
}
