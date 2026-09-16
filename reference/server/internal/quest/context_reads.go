package quest

import "fmt"

type questReadContext struct {
	Player      PlayerInfo
	ZoneID      int32
	Globals     map[string]string
	ScriptState map[string]any
}

// All character-backed Lua events use the same eligibility projection. Trade
// removes offered items from HasItem, while dialogue and runtime events see
// the loaded inventory. Keep position and event-specific state at the caller.
func (player PlayerInfo) questPlayerProxy(characterID uint32, offeredItems []int) *PlayerProxy {
	return &PlayerProxy{
		ID: characterID, Name: player.Name,
		CharClass: player.ClassName, CharRace: player.RaceName, CharLevel: int(player.Level),
		ClassID: player.Class, RaceID: player.Race,
		Tasks: player.Tasks, Activities: player.Activities, Factions: player.Factions,
		Inventory: inventoryAfterTrade(player.Inventory, offeredItems),
	}
}

// Dialogue, trade and NPC/player events share the prerequisite read policy.
// A failed read is not an empty inventory, absent flag or fresh actor.
// This does not claim transactional isolation across these separate queries.
func (s *Service) loadQuestReadContext(characterID uint32, npcID int32, zone string, runtime QuestTurnInContext) (questReadContext, error) {
	var result questReadContext
	var err error
	if result.Player, err = s.getPlayerInfo(characterID); err != nil {
		return questReadContext{}, fmt.Errorf("load quest character %d: %w", characterID, err)
	}
	if result.ZoneID, err = s.getZoneID(zone); err != nil {
		return questReadContext{}, fmt.Errorf("load quest zone %s: %w", zone, err)
	}
	if result.Globals, err = s.getGlobals(characterID, npcID, result.ZoneID); err != nil {
		return questReadContext{}, fmt.Errorf("load quest globals: %w", err)
	}
	if result.ScriptState, err = s.loadRuntimeScriptState(characterID, npcID, zone, runtime.InstanceID, runtime.SpawnInstanceID); err != nil {
		return questReadContext{}, fmt.Errorf("load quest actor state: %w", err)
	}
	return result, nil
}
