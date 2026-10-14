package quest

import (
	"fmt"
	"sort"

	"idlequest/internal/constants"
	"idlequest/internal/db/items"
	"idlequest/internal/db/jetgen/eqgo/model"
)

const inventoryFullQuestMessage = "You do not have enough inventory space for the quest rewards. Your offered items and money remain in the give window."

type questItemConsumption struct {
	Key      constants.InventoryKey
	ItemID   int32
	Quantity int
}

func validateOfferedItems(inv map[constants.InventoryKey]*constants.ItemWithInstance, offered []QuestOfferedItem, itemIDs []int) error {
	if len(offered) == 0 { // Backward compatibility for server-side/debug callers.
		return nil
	}
	want := make(map[int]int)
	for _, id := range itemIDs {
		want[id]++
	}
	got := make(map[int]int)
	seen := make(map[constants.InventoryKey]bool)
	for _, offer := range offered {
		key := constants.InventoryKey{Bag: offer.Bag, Slot: offer.Slot}
		if offer.Bag != 0 || offer.Slot < constants.SlotTrade1 || offer.Slot > constants.SlotTrade4 || offer.Quantity <= 0 || seen[key] {
			return fmt.Errorf("invalid quest give-slot item")
		}
		seen[key] = true
		item := inv[key]
		if item == nil || item.Item.ID != int32(offer.ItemID) || int(item.Instance.Quantity) != offer.Quantity {
			return fmt.Errorf("quest give-slot items changed before the hand-in completed")
		}
		if offer.ItemInstanceID > 0 && item.ItemInstanceID != offer.ItemInstanceID {
			return fmt.Errorf("quest give-slot item instance changed before the hand-in completed")
		}
		got[offer.ItemID] += offer.Quantity
	}
	if len(want) != len(got) {
		return fmt.Errorf("quest give-slot items do not match the hand-in")
	}
	for id, count := range want {
		if got[id] != count {
			return fmt.Errorf("quest give-slot items do not match the hand-in")
		}
	}
	return nil
}

func buildQuestConsumptionPlan(inv map[constants.InventoryKey]*constants.ItemWithInstance, offered []QuestOfferedItem, consumedIDs []int) ([]questItemConsumption, error) {
	type candidate struct {
		key       constants.InventoryKey
		item      *constants.ItemWithInstance
		remaining int
	}
	candidates := make([]candidate, 0)
	if len(offered) > 0 {
		for _, offer := range offered {
			key := constants.InventoryKey{Bag: offer.Bag, Slot: offer.Slot}
			if item := inv[key]; item != nil {
				candidates = append(candidates, candidate{key: key, item: item, remaining: offer.Quantity})
			}
		}
	} else {
		for key, item := range inv {
			if item != nil {
				candidates = append(candidates, candidate{key: key, item: item, remaining: int(item.Instance.Quantity)})
			}
		}
		sort.Slice(candidates, func(i, j int) bool {
			iTrade := candidates[i].key.Bag == 0 && candidates[i].key.Slot >= constants.SlotTrade1 && candidates[i].key.Slot <= constants.SlotTrade4
			jTrade := candidates[j].key.Bag == 0 && candidates[j].key.Slot >= constants.SlotTrade1 && candidates[j].key.Slot <= constants.SlotTrade4
			if iTrade != jTrade {
				return iTrade
			}
			if candidates[i].key.Bag != candidates[j].key.Bag {
				return candidates[i].key.Bag < candidates[j].key.Bag
			}
			return candidates[i].key.Slot < candidates[j].key.Slot
		})
	}

	counts := make(map[constants.InventoryKey]int)
	for _, id := range consumedIDs {
		found := false
		for i := range candidates {
			if candidates[i].remaining > 0 && candidates[i].item.Item.ID == int32(id) {
				candidates[i].remaining--
				counts[candidates[i].key]++
				found = true
				break
			}
		}
		if !found {
			return nil, fmt.Errorf("a required quest item is no longer in the give window")
		}
	}

	plan := make([]questItemConsumption, 0, len(counts))
	for _, candidate := range candidates {
		if count := counts[candidate.key]; count > 0 {
			plan = append(plan, questItemConsumption{Key: candidate.key, ItemID: candidate.item.Item.ID, Quantity: count})
		}
	}
	return plan, nil
}

func preflightQuestRewards(inv map[constants.InventoryKey]*constants.ItemWithInstance, plan []questItemConsumption, rewards RewardSummary) error {
	simulated := make(map[constants.InventoryKey]*constants.ItemWithInstance, len(inv))
	for key, item := range inv {
		if item == nil {
			continue
		}
		copyItem := *item
		simulated[key] = &copyItem
	}
	for _, consume := range plan {
		item := simulated[consume.Key]
		if item == nil || int(item.Instance.Quantity) < consume.Quantity {
			return fmt.Errorf("a required quest item is no longer in the give window")
		}
		if int(item.Instance.Quantity) == consume.Quantity {
			delete(simulated, consume.Key)
		} else {
			item.Instance.Quantity -= uint8(consume.Quantity)
		}
	}
	// Any unconsumed offer must also fit back into carried inventory. Reserve
	// those destinations before reserving reward items.
	for slot := constants.SlotTrade1; slot <= constants.SlotTrade4; slot++ {
		tradeKey := constants.InventoryKey{Bag: 0, Slot: slot}
		tradeItem := simulated[tradeKey]
		if tradeItem == nil {
			continue
		}
		delete(simulated, tradeKey)
		bag, destination := items.FindFirstAvailableSlotOrCursor(simulated, tradeItem.IsContainer())
		if destination < 0 {
			return fmt.Errorf("%s", inventoryFullQuestMessage)
		}
		toKey := constants.InventoryKey{Bag: bag, Slot: destination}
		simulated[toKey] = tradeItem
		if tradeItem.IsContainer() {
			relocateQuestContainerContents(simulated, tradeKey.Slot, toKey.Slot)
		}
	}

	for _, reward := range rewards.Items {
		tmpl, err := items.GetAcquirableItemTemplateByID(int32(reward.ItemID))
		if err != nil {
			return fmt.Errorf("quest reward item %d is unavailable", reward.ItemID)
		}
		for count := 0; count < reward.Count; count++ {
			if err := validateQuestRewardLore(simulated, tmpl); err != nil {
				return err
			}
			stacked := false
			if tmpl.Stackable > 0 {
				for key, existing := range simulated {
					if isQuestCarriedInventoryKey(simulated, key) && existing.Item.ID == tmpl.ID && existing.Instance.Quantity < uint8(tmpl.Stacksize) {
						existing.Instance.Quantity++
						stacked = true
						break
					}
				}
			}
			if stacked {
				continue
			}
			bag, slot := items.FindFirstAvailableSlotOrCursor(simulated, tmpl.Bagslots > 0)
			if slot < 0 {
				return fmt.Errorf("%s", inventoryFullQuestMessage)
			}
			simulated[constants.InventoryKey{Bag: bag, Slot: slot}] = &constants.ItemWithInstance{Item: tmpl}
			simulated[constants.InventoryKey{Bag: bag, Slot: slot}].Instance.Quantity = 1
		}
	}
	return nil
}

func relocateQuestContainerContents(
	inventory map[constants.InventoryKey]*constants.ItemWithInstance,
	fromParentSlot int16,
	toParentSlot int16,
) []questInventoryMove {
	fromBag := fromParentSlot + 1
	toBag := toParentSlot + 1
	if fromBag == toBag {
		return nil
	}
	moves := make([]questInventoryMove, 0)
	for key, item := range inventory {
		if key.Bag != fromBag || item == nil {
			continue
		}
		to := constants.InventoryKey{Bag: toBag, Slot: key.Slot}
		delete(inventory, key)
		inventory[to] = item
		moves = append(moves, questInventoryMove{instanceID: item.ItemInstanceID, to: to})
	}
	return moves
}

func validateQuestRewardLore(
	inventory map[constants.InventoryKey]*constants.ItemWithInstance,
	template model.Items,
) error {
	candidate := &constants.ItemWithInstance{Item: template}
	if !candidate.IsLore() {
		return nil
	}
	for _, existing := range inventory {
		if candidate.CheckLoreConflict(existing) {
			return fmt.Errorf("you already possess the lore item %s", template.Name)
		}
	}
	return nil
}

func returnQuestGiveSlotItems(playerID int32, inv map[constants.InventoryKey]*constants.ItemWithInstance) error {
	for slot := constants.SlotTrade1; slot <= constants.SlotTrade4; slot++ {
		fromKey := constants.InventoryKey{Bag: 0, Slot: slot}
		tradeItem := inv[fromKey]
		if tradeItem == nil {
			continue
		}
		toBag, toSlot := items.FindFirstAvailableSlotOrCursor(inv, tradeItem.IsContainer())
		if toSlot < 0 {
			return fmt.Errorf("%s", inventoryFullQuestMessage)
		}
		toKey := constants.InventoryKey{Bag: toBag, Slot: toSlot}
		updates, err := items.SwapItemSlots(playerID, fromKey.Slot, toKey.Slot, toKey.Bag, fromKey.Bag, tradeItem, nil)
		if err != nil {
			return fmt.Errorf("return give-slot item: %w", err)
		}
		applyQuestInventorySlotUpdates(inv, updates)
	}
	return nil
}

func applyQuestInventorySlotUpdates(
	inventory map[constants.InventoryKey]*constants.ItemWithInstance,
	updates []items.SlotUpdate,
) {
	moving := make(map[int32]*constants.ItemWithInstance, len(updates))
	for _, update := range updates {
		from := constants.InventoryKey{Bag: update.FromBag, Slot: update.FromSlot}
		if item := inventory[from]; item != nil {
			moving[update.ItemInstanceID] = item
		}
	}
	for _, update := range updates {
		delete(inventory, constants.InventoryKey{Bag: update.FromBag, Slot: update.FromSlot})
	}
	for _, update := range updates {
		if item := moving[update.ItemInstanceID]; item != nil {
			inventory[constants.InventoryKey{Bag: update.ToBag, Slot: update.ToSlot}] = item
		}
	}
}

func isQuestCarriedInventoryKey(inv map[constants.InventoryKey]*constants.ItemWithInstance, key constants.InventoryKey) bool {
	if key.Bag == 0 {
		return constants.IsGeneralSlot(key.Slot)
	}
	parentSlot := key.Bag - 1
	container := inv[constants.InventoryKey{Bag: 0, Slot: parentSlot}]
	return constants.IsGeneralSlot(parentSlot) && container != nil && container.IsContainer() && key.Slot >= 0 && key.Slot < int16(container.Item.Bagslots)
}
