package quest

import (
	"context"
	"fmt"

	"github.com/go-jet/jet/v2/stmtcache"
	"idlequest/internal/constants"
	"idlequest/internal/db"
)

// SettleRuntimeItemClaim commits a world-source claim and its inventory reward
// together. The callback must use the supplied transaction and must not mutate
// session state. A failed claim, stale inventory, grant or commit returns no
// inventory projection; the caller publishes only the committed result.
func SettleRuntimeItemClaim(ctx context.Context, characterID uint32,
	inventory map[constants.InventoryKey]*constants.ItemWithInstance,
	rewards RewardSummary, claim func(*stmtcache.Tx) error,
) (map[constants.InventoryKey]*constants.ItemWithInstance, error) {
	if claim == nil || db.GlobalWorldDB == nil || db.GlobalWorldDB.DB == nil {
		return nil, fmt.Errorf("item settlement is unavailable")
	}
	if len(rewards.Items) != 1 || rewards.Items[0].Count != 1 {
		return nil, fmt.Errorf("world pickup must grant exactly one item")
	}
	planned, err := buildQuestInventoryPlan(inventory, nil, rewards, false)
	if err != nil {
		return nil, err
	}
	return settleRuntimeItemPlan(ctx, characterID, inventory, planned, claim)
}

func settleRuntimeItemPlan(ctx context.Context, characterID uint32,
	inventory map[constants.InventoryKey]*constants.ItemWithInstance,
	planned *questSettlementInventory, claim func(*stmtcache.Tx) error,
) (map[constants.InventoryKey]*constants.ItemWithInstance, error) {
	tx, err := db.GlobalWorldDB.DB.BeginTx(ctx, nil)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback()
	if err = lockQuestInventorySnapshot(ctx, tx, characterID, inventory); err != nil {
		return nil, err
	}
	if err = claim(tx); err != nil {
		return nil, err
	}
	if err = applyQuestInventoryPlan(ctx, tx, characterID, planned); err != nil {
		return nil, err
	}
	if err = tx.Commit(); err != nil {
		return nil, err
	}
	return planned.final, nil
}
