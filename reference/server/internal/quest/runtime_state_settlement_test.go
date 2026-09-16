package quest

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/go-jet/jet/v2/stmtcache"
	"github.com/stretchr/testify/require"
)

// Called by the opt-in local SQL harness after it establishes connection-local
// temporary tables and disables reconnects. This tests real commit/rollback and
// stale snapshots, not concurrent scheduling across database connections.
func assertRuntimeStateTransactions(t *testing.T, ctx context.Context, database *stmtcache.DB) {
	const owner uint32 = 610002
	first := NPCAddedLoot{NPCID: 9001, SpawnInstanceID: 5001, ItemID: 18099, Count: 1}
	second := first
	second.ItemID = 1888
	write := func(state map[string]any, delta []NPCAddedLoot, commit bool) error {
		tx, err := database.BeginTx(ctx, nil)
		require.NoError(t, err)
		defer tx.Rollback()
		err = PersistRuntimeScriptStateTx(ctx, tx, owner, 9001, "testzone", 0, 5001, state, delta)
		if err == nil && commit {
			err = tx.Commit()
		}
		return err
	}
	read := func() map[string]any {
		var encoded []byte
		require.NoError(t, database.QueryRowContext(ctx, `SELECT state_json FROM quest_runtime_script_state WHERE owner_character_id=? AND zone_name='testzone' AND instance_id=0 AND spawn_instance_id=5001`, owner).Scan(&encoded))
		var state map[string]any
		require.NoError(t, json.Unmarshal(encoded, &state))
		return state
	}
	stale := map[string]any{"stage": 1, NPCAddedLootScriptStateKey: []NPCAddedLoot{first}}
	require.NoError(t, write(stale, []NPCAddedLoot{first}, true))
	require.NoError(t, write(nil, []NPCAddedLoot{second}, true))
	require.NoError(t, write(stale, nil, true))
	state := read()
	items, err := NPCAddedLootFromScriptState(state)
	require.NoError(t, err)
	require.Equal(t, []NPCAddedLoot{first, second}, items)
	require.Equal(t, float64(1), state["stage"])

	// A later failure in the surrounding settlement must roll back both the
	// inventory delta and Lua progress, not just the character's inventory.
	require.NoError(t, write(map[string]any{"stage": 2}, []NPCAddedLoot{second}, false))
	require.Equal(t, state, read())
	foreign := first
	foreign.SpawnInstanceID++
	require.ErrorContains(t, write(map[string]any{"stage": 3}, []NPCAddedLoot{foreign}, true), "does not belong")
	require.Equal(t, state, read())

	// Even an actor with no inventory has an identity. A mismatched lookup
	// must not relabel its state row before writing another NPC's inventory.
	tx, err := database.BeginTx(ctx, nil)
	require.NoError(t, err)
	require.NoError(t, PersistRuntimeScriptStateTx(ctx, tx, owner, 9001, "testzone", 0, 5002,
		map[string]any{"stage": 4}, nil))
	require.NoError(t, tx.Commit())
	tx, err = database.BeginTx(ctx, nil)
	require.NoError(t, err)
	wrongActor := NPCAddedLoot{NPCID: 9002, SpawnInstanceID: 5002, ItemID: 1888, Count: 1}
	err = PersistRuntimeScriptStateTx(ctx, tx, owner, 9002, "testzone", 0, 5002, nil, []NPCAddedLoot{wrongActor})
	// Roll back before asserting so failure cannot strand the sole test connection.
	require.NoError(t, tx.Rollback())
	require.ErrorContains(t, err, "belongs to NPC 9001, not 9002")
	var storedNPC int32
	var encoded []byte
	require.NoError(t, database.QueryRowContext(ctx, `SELECT npc_type_id,state_json FROM quest_runtime_script_state WHERE owner_character_id=? AND zone_name='testzone' AND instance_id=0 AND spawn_instance_id=5002`, owner).Scan(&storedNPC, &encoded))
	require.Equal(t, int32(9001), storedNPC)
	var unchanged map[string]any
	require.NoError(t, json.Unmarshal(encoded, &unchanged))
	require.Equal(t, map[string]any{"stage": float64(4)}, unchanged)
	reader := NewService(database, ".")
	loaded, err := reader.loadRuntimeScriptState(owner, 9001, "testzone", 0, 5002)
	require.NoError(t, err)
	require.Equal(t, unchanged, loaded)
	loaded, err = reader.loadRuntimeScriptState(owner, 9002, "testzone", 0, 5002)
	require.ErrorContains(t, err, "belongs to NPC 9001, not 9002")
	require.Nil(t, loaded, "quest variables must not leak to a different NPC")
	loot, err := reader.RuntimeNPCAddedLoot(owner, 9002, "testzone", 0, 5002)
	require.ErrorContains(t, err, "belongs to NPC 9001, not 9002")
	require.Nil(t, loot, "empty inventory does not make a mismatched actor valid")
}

func TestRuntimeInventoryMergePreservesInterleavedAdditions(t *testing.T) {
	first := NPCAddedLoot{NPCID: 9001, SpawnInstanceID: 5001, ItemID: 18099, Count: 1}
	second, third := first, first
	second.ItemID, third.ItemID = 1888, 1889
	current := map[string]any{"stage": 1, NPCAddedLootScriptStateKey: []NPCAddedLoot{first, second}}
	stale := map[string]any{"stage": 2, NPCAddedLootScriptStateKey: []NPCAddedLoot{first, third}}
	merged, err := mergeRuntimeInventoryState(current, stale, 9001, 5001, []NPCAddedLoot{third})
	require.NoError(t, err)
	items, err := NPCAddedLootFromScriptState(merged)
	require.NoError(t, err)
	require.Equal(t, []NPCAddedLoot{first, second, third}, items)
	require.Equal(t, 2, merged["stage"])
	require.Equal(t, []NPCAddedLoot{first, second}, current[NPCAddedLootScriptStateKey])
	require.Equal(t, []NPCAddedLoot{first, third}, stale[NPCAddedLootScriptStateKey])

	// A callback with no new inventory must not re-append its old snapshot.
	merged, err = mergeRuntimeInventoryState(merged, stale, 9001, 5001, nil)
	require.NoError(t, err)
	items, err = NPCAddedLootFromScriptState(merged)
	require.NoError(t, err)
	require.Len(t, items, 3)
	// Inventory-only routing to another actor cannot erase its Lua progress.
	merged, err = mergeRuntimeInventoryState(merged, nil, 9001, 5001, []NPCAddedLoot{third})
	require.NoError(t, err)
	require.Equal(t, 2, merged["stage"])
	items, err = NPCAddedLootFromScriptState(merged)
	require.NoError(t, err)
	require.Len(t, items, 4, "two deliberate AddItem calls may create identical items")
}

func TestRuntimeInventoryMergeRejectsForeignDeltaAndCorruption(t *testing.T) {
	for _, item := range []NPCAddedLoot{
		{NPCID: 9002, ItemID: 18099},
		{NPCID: 9001, ItemID: 18099, SpawnInstanceID: 5002},
		{NPCID: 9001, ItemID: 18099, Count: -2},
	} {
		merged, err := mergeRuntimeInventoryState(nil, map[string]any{"stage": 2}, 9001, 5001, []NPCAddedLoot{item})
		require.ErrorContains(t, err, "does not belong")
		require.Nil(t, merged)
	}
	_, err := mergeRuntimeInventoryState(map[string]any{NPCAddedLootScriptStateKey: "broken"}, nil, 9001, 5001, nil)
	require.ErrorContains(t, err, "decode quest NPC inventory")
}
