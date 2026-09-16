package quest

import (
	"context"
	"encoding/json"
	"fmt"
	"log"

	"idlequest/internal/api/opcodes"
	"idlequest/internal/constants"
	db_character "idlequest/internal/db/character"
	dbitems "idlequest/internal/db/items"
	"idlequest/internal/session"
)

func reloadQuestInventoryFromDB(ses *session.Session) error {
	rows, err := db_character.GetCharacterItems(context.Background(), int(ses.Client.CharData().ID))
	if err != nil {
		return err
	}
	loaded := make(map[constants.InventoryKey]*constants.ItemWithInstance, len(rows))
	for _, row := range rows {
		template, err := dbitems.GetItemTemplateByID(row.ItemID)
		if err != nil {
			return fmt.Errorf("load item template %d: %w", row.ItemID, err)
		}
		instance := constants.ItemInstance{
			ID:        row.ItemInstanceID,
			ItemID:    row.ItemID,
			Charges:   row.Charges,
			Quantity:  row.Quantity,
			OwnerID:   row.OwnerID,
			OwnerType: constants.OwnerType(row.OwnerType),
		}
		if row.Mods != nil {
			_ = json.Unmarshal([]byte(*row.Mods), &instance.Mods)
		}
		loaded[constants.InventoryKey{Bag: row.Bag, Slot: row.Slot}] = &constants.ItemWithInstance{
			Item:           template,
			Instance:       instance,
			BagSlot:        row.Bag,
			ItemInstanceID: row.ItemInstanceID,
		}
	}
	ses.Client.WithItemsMutate(func(current map[constants.InventoryKey]*constants.ItemWithInstance) {
		for key := range current {
			delete(current, key)
		}
		for key, item := range loaded {
			current[key] = item
		}
	})
	return nil
}

// ReturnGiveSlotItemsForSession settles temporary NPC give slots back into
// carried inventory before lifecycle transitions can make the Give UI
// inaccessible. It is safe to call when no hand-in is staged.
func ReturnGiveSlotItemsForSession(ses *session.Session) error {
	if ses == nil || ses.Client == nil {
		return nil
	}
	var returnErr error
	ses.Client.WithItemsMutate(func(inventory map[constants.InventoryKey]*constants.ItemWithInstance) {
		returnErr = returnQuestGiveSlotItems(int32(ses.Client.CharData().ID), inventory)
	})
	return returnErr
}

func questCharacterSnapshot(ses *session.Session) (map[string]interface{}, map[string]interface{}, string) {
	if ses == nil || ses.Client == nil {
		return map[string]interface{}{}, map[string]interface{}{}, ""
	}
	ses.Client.WithItemsMutate(func(inventory map[constants.InventoryKey]*constants.ItemWithInstance) {
		if err := returnQuestGiveSlotItems(int32(ses.Client.CharData().ID), inventory); err != nil {
			log.Printf("[Quest] Failed to settle give slots for character %d: %v", ses.Client.CharData().ID, err)
			ses.Client.SendSystemMessage("Your give-window items could not be returned. Please make inventory space and contact support.")
		}
	})

	inventoryMap := make(map[string]interface{})
	for key, item := range ses.Client.Items() {
		if item != nil {
			inventoryMap[fmt.Sprintf("%d:%d", key.Bag, key.Slot)] = toMap(item)
		}
	}
	currencyMap := make(map[string]interface{})
	currency, err := db_character.GetCharacterCurrency(context.Background(), uint32(ses.Client.CharData().ID))
	if err == nil {
		currencyMap = map[string]interface{}{
			"platinum": currency.Platinum,
			"gold":     currency.Gold,
			"silver":   currency.Silver,
			"copper":   currency.Copper,
		}
	}
	return inventoryMap, currencyMap, dbitems.InventoryRevision(ses.Client.Items())
}

func sendQuestCharacterSnapshots(ses *session.Session) string {
	inventory, currency, revision := questCharacterSnapshot(ses)
	ses.SendStreamJSON(inventory, opcodes.CharacterInventory)
	if len(currency) > 0 {
		ses.SendStreamJSON(currency, opcodes.CharacterCurrency)
	}
	return revision
}

func sendQuestTurnInResponse(ses *session.Session, req QuestTurnInRequest, response *QuestTurnInResponse) {
	if err := reloadQuestInventoryFromDB(ses); err != nil {
		log.Printf("[Quest] Failed final inventory reload for transaction %s: %v", req.TransactionID, err)
		ses.Client.SendSystemMessage("Your final inventory state could not be reloaded. Please use Retry Sync.")
		return
	}
	response.TransactionID = req.TransactionID
	response.FinalInventoryRevision = sendQuestCharacterSnapshots(ses)
	ses.SendStreamJSON(response, opcodes.QuestTurnInResponse)
}

func HandleCharacterStateRefreshRequest(ses *session.Session, payload []byte) bool {
	var req CharacterStateRefreshRequest
	if err := json.Unmarshal(payload, &req); err != nil {
		return false
	}
	if err := reloadQuestInventoryFromDB(ses); err != nil {
		log.Printf("[Quest] Failed authoritative inventory reload for transaction %s: %v", req.TransactionID, err)
		ses.Client.SendSystemMessage("Your inventory could not be refreshed from the server. Please retry.")
		return false
	}
	inventory, currency, revision := questCharacterSnapshot(ses)
	ses.SendStreamJSON(CharacterStateRefreshResponse{
		TransactionID:     req.TransactionID,
		InventoryRevision: revision,
		Inventory:         inventory,
		Currency:          currency,
	}, opcodes.CharacterStateRefreshResponse)
	return false
}
