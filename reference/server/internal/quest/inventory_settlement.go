package quest

import (
	"context"
	"fmt"

	"github.com/go-jet/jet/v2/stmtcache"
	"idlequest/internal/constants"
	dbitems "idlequest/internal/db/items"
)

func lockQuestInventorySnapshot(ctx context.Context, tx *stmtcache.Tx, characterID uint32, inventory map[constants.InventoryKey]*constants.ItemWithInstance) error {
	var err error
	lockedRows, lockErr := tx.QueryContext(ctx, `SELECT ci.bag, ci.slot, ii.id, ii.item_id, ii.quantity FROM character_inventory ci JOIN item_instances ii ON ii.id=ci.item_instance_id WHERE ci.character_id=? FOR UPDATE`, characterID)
	if lockErr != nil {
		return fmt.Errorf("lock quest inventory: %w", lockErr)
	}
	lockedCount := 0
	for lockedRows.Next() {
		var bag, slot int16
		var instanceID, itemID int32
		var quantity uint8
		if err = lockedRows.Scan(&bag, &slot, &instanceID, &itemID, &quantity); err != nil {
			_ = lockedRows.Close()
			return fmt.Errorf("read locked quest inventory: %w", err)
		}
		expected := inventory[constants.InventoryKey{Bag: bag, Slot: slot}]
		if expected == nil || expected.ItemInstanceID != instanceID || expected.Item.ID != itemID || expected.Instance.Quantity != quantity {
			_ = lockedRows.Close()
			return fmt.Errorf("inventory changed before quest settlement")
		}
		lockedCount++
	}
	if err = lockedRows.Err(); err != nil {
		_ = lockedRows.Close()
		return fmt.Errorf("read locked quest inventory: %w", err)
	}
	if closeErr := lockedRows.Close(); closeErr != nil {
		return fmt.Errorf("close locked quest inventory: %w", closeErr)
	}
	if lockedCount != len(inventory) {
		return fmt.Errorf("inventory changed before quest settlement")
	}

	return nil
}

func applyQuestInventoryPlan(ctx context.Context, tx *stmtcache.Tx, characterID uint32, planned *questSettlementInventory) error {
	var err error
	for instanceID, quantity := range planned.quantities {
		if _, err = tx.ExecContext(ctx, `UPDATE item_instances SET quantity=? WHERE id=? AND owner_id=?`, quantity, instanceID, characterID); err != nil {
			return fmt.Errorf("update quest item quantity: %w", err)
		}
	}
	for _, instanceID := range planned.deleted {
		if _, err = tx.ExecContext(ctx, `DELETE FROM item_instances WHERE id=? AND owner_id=?`, instanceID, characterID); err != nil {
			return fmt.Errorf("consume quest item: %w", err)
		}
	}
	for _, move := range planned.moves {
		if _, err = tx.ExecContext(ctx, `UPDATE character_inventory SET bag=?, slot=? WHERE character_id=? AND item_instance_id=?`, move.to.Bag, move.to.Slot, characterID, move.instanceID); err != nil {
			return fmt.Errorf("return quest give-slot item: %w", err)
		}
	}
	for _, creation := range planned.rewardCreations {
		item := planned.final[creation.key]
		instanceID, createErr := dbitems.CreateDBItemInstance(tx, item.Instance, int32(characterID))
		if createErr != nil {
			return fmt.Errorf("create quest reward: %w", createErr)
		}
		item.ItemInstanceID = instanceID
		item.Instance.ID = instanceID
		if _, err = tx.ExecContext(ctx, `INSERT INTO character_inventory (character_id, slot, item_instance_id, bag) VALUES (?, ?, ?, ?)`, characterID, creation.key.Slot, instanceID, creation.key.Bag); err != nil {
			return fmt.Errorf("place quest reward: %w", err)
		}
	}

	return nil
}
