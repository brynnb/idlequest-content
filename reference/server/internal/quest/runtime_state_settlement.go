package quest

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/go-jet/jet/v2/stmtcache"
)

// PersistRuntimeScriptStateTx preserves physical NPC inventory independently
// of a callback's older Lua-variable snapshot. Callers supply only this
// event's AddItem delta, never its cumulative inventory snapshot.
func PersistRuntimeScriptStateTx(ctx context.Context, tx *stmtcache.Tx, owner uint32, npcID int32, zone string, instance int, stateKey int64, incoming map[string]any, added []NPCAddedLoot) error {
	if stateKey == 0 || (len(incoming) == 0 && len(added) == 0) {
		return nil
	}
	// Materialize and lock even a previously absent row before reading. All
	// inventory writers must take this row lock; a SELECT of a missing row
	// alone is not sufficient to serialize two first-time writers.
	if _, err := tx.ExecContext(ctx, `INSERT INTO quest_runtime_script_state (owner_character_id, zone_name, instance_id, spawn_instance_id, npc_type_id, state_json) VALUES (?, ?, ?, ?, ?, '{}') ON DUPLICATE KEY UPDATE spawn_instance_id=VALUES(spawn_instance_id)`, owner, zone, instance, stateKey, npcID); err != nil {
		return fmt.Errorf("lock quest script state: %w", err)
	}
	var encoded []byte
	var storedNPCID int32
	if err := tx.QueryRowContext(ctx, `SELECT npc_type_id, state_json FROM quest_runtime_script_state WHERE owner_character_id=? AND zone_name=? AND instance_id=? AND spawn_instance_id=? FOR UPDATE`, owner, zone, instance, stateKey).Scan(&storedNPCID, &encoded); err != nil {
		return fmt.Errorf("read quest script state: %w", err)
	}
	// Inventory may be empty, so its entries cannot establish actor identity.
	// Validate the locked row before accepting an inventory-only delivery.
	if storedNPCID != npcID {
		return fmt.Errorf("quest state spawn %d belongs to NPC %d, not %d", stateKey, storedNPCID, npcID)
	}
	var current map[string]any
	if err := json.Unmarshal(encoded, &current); err != nil {
		return fmt.Errorf("decode quest script state: %w", err)
	}
	merged, err := mergeRuntimeInventoryState(current, incoming, npcID, stateKey, added)
	if err != nil {
		return err
	}
	encoded, err = json.Marshal(merged)
	if err != nil {
		return fmt.Errorf("encode quest script state: %w", err)
	}
	_, err = tx.ExecContext(ctx, `UPDATE quest_runtime_script_state SET state_json=? WHERE owner_character_id=? AND zone_name=? AND instance_id=? AND spawn_instance_id=? AND npc_type_id=?`, encoded, owner, zone, instance, stateKey, npcID)
	return err
}

func mergeRuntimeInventoryState(current, incoming map[string]any, npcID int32, stateKey int64, added []NPCAddedLoot) (map[string]any, error) {
	stored, err := npcAddedLootForActor(current, npcID, stateKey)
	if err != nil {
		return nil, err
	}
	merged := cloneScriptState(incoming)
	if incoming == nil {
		merged = cloneScriptState(current) // Inventory-only delivery keeps Lua variables.
	}
	delete(merged, NPCAddedLootScriptStateKey)
	for _, item := range added {
		if item.NPCID != npcID || item.ItemID <= 0 || item.Count < -1 || (item.SpawnInstanceID != 0 && item.SpawnInstanceID != stateKey) {
			return nil, fmt.Errorf("quest inventory delta does not belong to NPC %d spawn %d", npcID, stateKey)
		}
		stored = append(stored, item)
	}
	if len(stored) > 0 {
		merged[NPCAddedLootScriptStateKey] = stored
	}
	return merged, nil
}
