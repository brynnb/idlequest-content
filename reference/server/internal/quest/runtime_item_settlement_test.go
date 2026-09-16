package quest

import (
	"database/sql"
	"errors"
	"testing"

	"github.com/go-jet/jet/v2/stmtcache"
	"github.com/stretchr/testify/require"
	"idlequest/internal/constants"
	"idlequest/internal/db"
	"idlequest/internal/testutil"
)

// All writes use connection-local temporary tables shadowing the real schema.
// A single physical connection is required; never run this test in parallel.
func TestLocalRuntimeItemSettlementAtomicity(t *testing.T) {
	ctx, raw := testutil.LocalTemporaryTables(t, "character_inventory", "item_instances", "quest_runtime_script_state")
	_, err := raw.ExecContext(ctx, "CREATE TEMPORARY TABLE _quest_claim_fixture (id INT PRIMARY KEY, claimed BOOL NOT NULL) ENGINE=InnoDB")
	require.NoError(t, err)
	previous := db.GlobalWorldDB
	// Statement-cache misses prepare through a second pool connection. Temp
	// tables are connection-local, so this fixture executes directly on its
	// sole transaction connection; production pool settings are unchanged.
	db.GlobalWorldDB = &db.WorldDB{DB: stmtcache.New(raw).SetCaching(false)}
	t.Cleanup(func() { db.GlobalWorldDB = previous })
	t.Run("NPC inventory state transactions", func(t *testing.T) {
		assertRuntimeStateTransactions(t, ctx, db.GlobalWorldDB.DB)
	})
	const owner uint32 = 610001
	key := constants.InventoryKey{Bag: 0, Slot: constants.SlotGeneral1}
	newPlan := func() *questSettlementInventory {
		item := questTestItem(1888, 0, 1)
		item.Instance.ItemID = 1888
		item.Instance.OwnerType = constants.OwnerTypeCharacter
		return &questSettlementInventory{
			final:           map[constants.InventoryKey]*constants.ItemWithInstance{key: item},
			rewardCreations: []questRewardCreation{{key: key}},
		}
	}
	reset := func() {
		for _, query := range []string{"DELETE FROM character_inventory", "DELETE FROM item_instances", "DELETE FROM _quest_claim_fixture", "INSERT INTO _quest_claim_fixture VALUES (1,FALSE)"} {
			_, err := raw.ExecContext(ctx, query)
			require.NoError(t, err)
		}
	}
	claim := func(tx *stmtcache.Tx) error {
		result, err := tx.ExecContext(ctx, "UPDATE _quest_claim_fixture SET claimed=TRUE WHERE id=1 AND claimed=FALSE")
		if err != nil {
			return err
		}
		count, err := result.RowsAffected()
		if err != nil {
			return err
		}
		if count != 1 {
			return sql.ErrNoRows
		}
		return nil
	}
	assertStored := func(claimed bool, count int) {
		var actual bool
		require.NoError(t, raw.QueryRowContext(ctx, "SELECT claimed FROM _quest_claim_fixture WHERE id=1").Scan(&actual))
		require.Equal(t, claimed, actual)
		for _, table := range []string{"character_inventory", "item_instances"} {
			var actualCount int
			require.NoError(t, raw.QueryRowContext(ctx, "SELECT COUNT(*) FROM "+table).Scan(&actualCount))
			require.Equal(t, count, actualCount, table)
		}
	}
	t.Run("source error rolls back its write", func(t *testing.T) {
		reset()
		final, err := settleRuntimeItemPlan(ctx, owner, nil, newPlan(), func(tx *stmtcache.Tx) error {
			if err := claim(tx); err != nil {
				return err
			}
			return errors.New("injected source failure")
		})
		require.ErrorContains(t, err, "injected source failure")
		require.Nil(t, final)
		assertStored(false, 0)
	})
	t.Run("inventory placement failure rolls back claim and instance", func(t *testing.T) {
		reset()
		plan := newPlan()
		// Two creations for the same location force the real unique-slot
		// constraint to fail after the first instance and inventory insert.
		plan.rewardCreations = append(plan.rewardCreations, questRewardCreation{key: key})
		final, err := settleRuntimeItemPlan(ctx, owner, nil, plan, claim)
		require.ErrorContains(t, err, "place quest reward")
		require.Nil(t, final)
		assertStored(false, 0)
	})
	t.Run("stale inventory cannot claim", func(t *testing.T) {
		reset()
		stale := map[constants.InventoryKey]*constants.ItemWithInstance{key: questTestItem(999, 999, 1)}
		final, err := settleRuntimeItemPlan(ctx, owner, stale, newPlan(), claim)
		require.ErrorContains(t, err, "inventory changed")
		require.Nil(t, final)
		assertStored(false, 0)
	})
	t.Run("commit grants once and repeat cannot duplicate", func(t *testing.T) {
		reset()
		final, err := settleRuntimeItemPlan(ctx, owner, nil, newPlan(), claim)
		require.NoError(t, err)
		require.Positive(t, final[key].ItemInstanceID)
		assertStored(true, 1)
		repeated, err := settleRuntimeItemPlan(ctx, owner, final, newPlan(), claim)
		require.ErrorIs(t, err, sql.ErrNoRows)
		require.Nil(t, repeated)
		assertStored(true, 1)
	})
}
