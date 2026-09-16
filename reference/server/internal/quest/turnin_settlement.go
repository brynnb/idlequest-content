package quest

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"github.com/go-jet/jet/v2/stmtcache"
	"idlequest/internal/constants"
	dbitems "idlequest/internal/db/items"
	"idlequest/internal/mechanics"
)

type questInventoryMove struct {
	instanceID int32
	to         constants.InventoryKey
}

type questRewardCreation struct {
	key constants.InventoryKey
}

type questSettlementInventory struct {
	final           map[constants.InventoryKey]*constants.ItemWithInstance
	deleted         []int32
	quantities      map[int32]uint8
	moves           []questInventoryMove
	rewardCreations []questRewardCreation
}

func cloneQuestInventory(source map[constants.InventoryKey]*constants.ItemWithInstance) map[constants.InventoryKey]*constants.ItemWithInstance {
	cloned := make(map[constants.InventoryKey]*constants.ItemWithInstance, len(source))
	for key, item := range source {
		if item == nil {
			continue
		}
		copyItem := *item
		copyItem.Instance = item.Instance
		cloned[key] = &copyItem
	}
	return cloned
}

func buildQuestSettlementInventory(
	inventory map[constants.InventoryKey]*constants.ItemWithInstance,
	consumption []questItemConsumption,
	rewards RewardSummary,
) (*questSettlementInventory, error) {
	return buildQuestInventoryPlan(inventory, consumption, rewards, true)
}

// World-item rewards must not return or move items held in an unrelated give
// window. Both paths still share reward placement, stacking and lore checks.
func buildQuestInventoryPlan(
	inventory map[constants.InventoryKey]*constants.ItemWithInstance,
	consumption []questItemConsumption,
	rewards RewardSummary,
	returnGiveItems bool,
) (*questSettlementInventory, error) {
	result := &questSettlementInventory{
		final:      cloneQuestInventory(inventory),
		quantities: make(map[int32]uint8),
	}

	for _, consume := range consumption {
		item := result.final[consume.Key]
		if item == nil || int(item.Instance.Quantity) < consume.Quantity {
			return nil, fmt.Errorf("a required quest item is no longer in the give window")
		}
		if int(item.Instance.Quantity) == consume.Quantity {
			delete(result.final, consume.Key)
			result.deleted = append(result.deleted, item.ItemInstanceID)
		} else {
			item.Instance.Quantity -= uint8(consume.Quantity)
			result.quantities[item.ItemInstanceID] = item.Instance.Quantity
		}
	}

	for slot := constants.SlotTrade1; returnGiveItems && slot <= constants.SlotTrade4; slot++ {
		from := constants.InventoryKey{Bag: 0, Slot: slot}
		item := result.final[from]
		if item == nil {
			continue
		}
		delete(result.final, from)
		bag, destination := dbitems.FindFirstAvailableSlotOrCursor(result.final, item.IsContainer())
		if destination < 0 {
			return nil, fmt.Errorf("%s", inventoryFullQuestMessage)
		}
		to := constants.InventoryKey{Bag: bag, Slot: destination}
		result.final[to] = item
		result.moves = append(result.moves, questInventoryMove{instanceID: item.ItemInstanceID, to: to})
		if item.IsContainer() {
			result.moves = append(result.moves, relocateQuestContainerContents(result.final, from.Slot, to.Slot)...)
		}
	}

	for _, reward := range rewards.Items {
		template, err := dbitems.GetItemTemplateByID(int32(reward.ItemID))
		if err != nil {
			return nil, fmt.Errorf("quest reward item %d is unavailable", reward.ItemID)
		}
		for count := 0; count < reward.Count; count++ {
			if err := validateQuestRewardLore(result.final, template); err != nil {
				return nil, err
			}
			var stack *constants.ItemWithInstance
			if template.Stackable > 0 {
				for key, existing := range result.final {
					if isQuestCarriedInventoryKey(result.final, key) && existing.Item.ID == template.ID && existing.Instance.Quantity < uint8(template.Stacksize) {
						stack = existing
						break
					}
				}
			}
			if stack != nil {
				stack.Instance.Quantity++
				if stack.ItemInstanceID > 0 {
					result.quantities[stack.ItemInstanceID] = stack.Instance.Quantity
				}
				continue
			}

			bag, slot := dbitems.FindFirstAvailableSlotOrCursor(result.final, template.Bagslots > 0)
			if slot < 0 {
				return nil, fmt.Errorf("%s", inventoryFullQuestMessage)
			}
			key := constants.InventoryKey{Bag: bag, Slot: slot}
			item := &constants.ItemWithInstance{
				Item: template,
				Instance: constants.ItemInstance{
					ItemID:    template.ID,
					Charges:   1,
					Quantity:  1,
					OwnerType: constants.OwnerTypeCharacter,
				},
			}
			result.final[key] = item
			result.rewardCreations = append(result.rewardCreations, questRewardCreation{key: key})
		}
	}

	return result, nil
}

func (s *Service) settleQuestTurnIn(
	ctx context.Context,
	transactionID string,
	characterID uint32,
	npcID int32,
	zoneName string,
	runtimeContext QuestTurnInContext,
	consumption []questItemConsumption,
	consumedCurrency QuestCurrency,
	rewards RewardSummary,
	capture *QuestCapture,
	inventory map[constants.InventoryKey]*constants.ItemWithInstance,
) (map[constants.InventoryKey]*constants.ItemWithInstance, string, error) {
	if transactionID == "" || len(transactionID) > 64 {
		return nil, "", fmt.Errorf("invalid quest transaction ID")
	}
	planned, err := buildQuestSettlementInventory(inventory, consumption, rewards)
	if err != nil {
		return nil, "", err
	}
	zoneID, err := s.getZoneID(zoneName)
	if err != nil {
		return nil, "", fmt.Errorf("resolve quest zone: %w", err)
	}
	effects, err := s.prepareRuntimeEffects(characterID, npcID, zoneName, runtimeContext, capture)
	if err != nil {
		return nil, "", err
	}

	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return nil, "", fmt.Errorf("begin quest settlement: %w", err)
	}
	defer func() { _ = tx.Rollback() }()

	if _, err = tx.ExecContext(ctx, `INSERT INTO quest_turnin_transactions (transaction_id, character_id, inventory_revision) VALUES (?, ?, '')`, transactionID, characterID); err != nil {
		return nil, "", fmt.Errorf("record quest transaction: %w", err)
	}
	if err = lockQuestInventorySnapshot(ctx, tx, characterID, inventory); err != nil {
		return nil, "", err
	}
	for _, consume := range consumption {
		var instanceID int32
		var itemID int32
		var quantity uint8
		err = tx.QueryRowContext(ctx, `SELECT ci.item_instance_id, ii.item_id, ii.quantity FROM character_inventory ci JOIN item_instances ii ON ii.id=ci.item_instance_id WHERE ci.character_id=? AND ci.bag=? AND ci.slot=? FOR UPDATE`, characterID, consume.Key.Bag, consume.Key.Slot).Scan(&instanceID, &itemID, &quantity)
		expected := inventory[consume.Key]
		if err != nil || expected == nil || instanceID != expected.ItemInstanceID || itemID != consume.ItemID || int(quantity) < consume.Quantity {
			return nil, "", fmt.Errorf("quest give-slot item changed before settlement")
		}
	}

	if err = applyQuestInventoryPlan(ctx, tx, characterID, planned); err != nil {
		return nil, "", err
	}
	if err = settleQuestCurrency(ctx, tx, characterID, consumedCurrency, rewards.Currency); err != nil {
		return nil, "", err
	}
	if err = s.persistQuestCaptureTx(ctx, tx, characterID, npcID, zoneID, zoneName, runtimeContext, capture); err != nil {
		return nil, "", err
	}

	revision := dbitems.InventoryRevision(planned.final)
	if _, err = tx.ExecContext(ctx, `UPDATE quest_turnin_transactions SET inventory_revision=? WHERE transaction_id=?`, revision, transactionID); err != nil {
		return nil, "", fmt.Errorf("finalize quest transaction: %w", err)
	}
	if err = effects.persist(ctx, tx); err != nil {
		return nil, "", err
	}
	if err = tx.Commit(); err != nil {
		return nil, "", fmt.Errorf("commit quest settlement: %w", err)
	}
	effects.publish()
	return planned.final, revision, nil
}

func settleQuestCurrency(ctx context.Context, tx *stmtcache.Tx, characterID uint32, consumed QuestCurrency, reward QuestCurrency) error {
	var platinum, gold, silver, copper int
	err := tx.QueryRowContext(ctx, `SELECT platinum, gold, silver, copper FROM character_currency WHERE id=? FOR UPDATE`, characterID).Scan(&platinum, &gold, &silver, &copper)
	if err == sql.ErrNoRows {
		platinum, gold, silver, copper = 0, 0, 0, 0
	} else if err != nil {
		return fmt.Errorf("lock quest currency: %w", err)
	}
	final, err := calculateQuestCurrencySettlement(
		QuestCurrency{Platinum: platinum, Gold: gold, Silver: silver, Copper: copper},
		consumed,
		reward,
	)
	if err != nil {
		return err
	}
	_, err = tx.ExecContext(ctx, `INSERT INTO character_currency (id, platinum, gold, silver, copper) VALUES (?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE platinum=VALUES(platinum), gold=VALUES(gold), silver=VALUES(silver), copper=VALUES(copper)`, characterID, final.Platinum, final.Gold, final.Silver, final.Copper)
	if err != nil {
		return fmt.Errorf("settle quest currency: %w", err)
	}
	return nil
}

func calculateQuestCurrencySettlement(current QuestCurrency, consumed QuestCurrency, reward QuestCurrency) (QuestCurrency, error) {
	final := QuestCurrency{
		Platinum: current.Platinum - consumed.Platinum + reward.Platinum,
		Gold:     current.Gold - consumed.Gold + reward.Gold,
		Silver:   current.Silver - consumed.Silver + reward.Silver,
		Copper:   current.Copper - consumed.Copper + reward.Copper,
	}
	if final.Platinum < 0 || final.Gold < 0 || final.Silver < 0 || final.Copper < 0 {
		return QuestCurrency{}, fmt.Errorf("offered quest currency is no longer available")
	}
	return final, nil
}

func (s *Service) persistQuestCaptureTx(
	ctx context.Context,
	tx *stmtcache.Tx,
	characterID uint32,
	npcID int32,
	zoneID int32,
	zoneName string,
	runtimeContext QuestTurnInContext,
	capture *QuestCapture,
) error {
	for _, update := range capture.Globals {
		if update.Delete {
			if _, err := tx.ExecContext(ctx, deleteQuestGlobalSQL, update.Name, npcID, characterID, zoneID); err != nil {
				return fmt.Errorf("delete quest global: %w", err)
			}
			continue
		}
		charID, scopedNPCID, scopedZoneID := questGlobalScopeIDs(characterID, npcID, zoneID, update.Options)
		if _, err := tx.ExecContext(ctx, `REPLACE INTO quest_globals (charid, npcid, zoneid, name, value, expdate) VALUES (?, ?, ?, ?, ?, ?)`, charID, scopedNPCID, scopedZoneID, update.Name, update.Value, questGlobalExpiration(update.Duration, time.Now().Unix())); err != nil {
			return fmt.Errorf("persist quest global: %w", err)
		}
	}
	if capture.Exp > 0 {
		var currentExp uint32
		var currentLevel uint32
		var raceID uint16
		var classID uint8
		if err := tx.QueryRowContext(ctx, `SELECT exp, level, race, class FROM character_data WHERE id=? FOR UPDATE`, characterID).Scan(&currentExp, &currentLevel, &raceID, &classID); err != nil {
			return fmt.Errorf("load character experience: %w", err)
		}
		newExp := mechanics.AddExperience(currentExp, capture.Exp, int(raceID), int(classID))
		newLevel := mechanics.CalculateLevelAfterExperienceGain(int(currentLevel), newExp, int(raceID), int(classID))
		if _, err := tx.ExecContext(ctx, `UPDATE character_data SET exp=?, level=? WHERE id=?`, newExp, newLevel, characterID); err != nil {
			return fmt.Errorf("grant quest experience: %w", err)
		}
	}
	for _, faction := range capture.Factions {
		if _, err := tx.ExecContext(ctx, `INSERT INTO faction_values (char_id, faction_id, current_value) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE current_value=current_value+VALUES(current_value)`, characterID, faction.FactionID, faction.Amount); err != nil {
			return fmt.Errorf("update quest faction: %w", err)
		}
	}
	for _, skill := range capture.SkillUpdates {
		if skill.SkillID < 0 || skill.SkillID > constants.Skill_HIGHEST {
			continue
		}
		if _, err := tx.ExecContext(ctx, `INSERT INTO character_skills (id, skill_id, value) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE value=VALUES(value)`, characterID, skill.SkillID, skill.Value); err != nil {
			return fmt.Errorf("update quest skill: %w", err)
		}
	}
	for _, task := range capture.Tasks {
		if task.Action == "assign" {
			if _, err := tx.ExecContext(ctx, `INSERT IGNORE INTO character_tasks (charid, taskid, acceptedtime) VALUES (?, ?, ?)`, characterID, task.TaskID, time.Now().Unix()); err != nil {
				return fmt.Errorf("assign quest task: %w", err)
			}
		}
	}

	return persistQuestEventStatesTx(ctx, tx, characterID, npcID, zoneName, runtimeContext, capture)
}
