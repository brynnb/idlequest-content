package quest

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"idlequest/internal/constants"
	dbitems "idlequest/internal/db/items"
	"idlequest/internal/db/jetgen/eqgo/model"
)

func questTestItem(itemID int32, instanceID int32, quantity uint8) *constants.ItemWithInstance {
	return &constants.ItemWithInstance{
		Item:           model.Items{ID: itemID},
		ItemInstanceID: instanceID,
		Instance:       constants.ItemInstance{Quantity: quantity},
	}
}

func TestValidateOfferedItemsRequiresExactGiveSlotInstances(t *testing.T) {
	key := constants.InventoryKey{Bag: 0, Slot: constants.SlotTrade1}
	inv := map[constants.InventoryKey]*constants.ItemWithInstance{key: questTestItem(100, 500, 3)}
	offered := []QuestOfferedItem{{ItemInstanceID: 500, ItemID: 100, Bag: 0, Slot: constants.SlotTrade1, Quantity: 3}}

	require.NoError(t, validateOfferedItems(inv, offered, []int{100, 100, 100}))
	assert.Error(t, validateOfferedItems(inv, offered, []int{100, 100}))

	offered[0].ItemInstanceID = 501
	assert.Error(t, validateOfferedItems(inv, offered, []int{100, 100, 100}))
}

func TestBuildQuestConsumptionPlanUsesOfferedInstanceNotDuplicate(t *testing.T) {
	tradeKey := constants.InventoryKey{Bag: 0, Slot: constants.SlotTrade1}
	carriedKey := constants.InventoryKey{Bag: 0, Slot: constants.SlotGeneral1}
	inv := map[constants.InventoryKey]*constants.ItemWithInstance{
		tradeKey:   questTestItem(100, 500, 3),
		carriedKey: questTestItem(100, 600, 1),
	}
	offered := []QuestOfferedItem{{ItemInstanceID: 500, ItemID: 100, Bag: 0, Slot: constants.SlotTrade1, Quantity: 3}}

	plan, err := buildQuestConsumptionPlan(inv, offered, []int{100, 100})
	require.NoError(t, err)
	require.Len(t, plan, 1)
	assert.Equal(t, tradeKey, plan[0].Key)
	assert.Equal(t, 2, plan[0].Quantity)
}

func TestPreflightUsesCursorOverflowForReturnedGiveItem(t *testing.T) {
	inv := make(map[constants.InventoryKey]*constants.ItemWithInstance)
	for slot := constants.SlotGeneral1; slot <= constants.SlotGeneral8; slot++ {
		inv[constants.InventoryKey{Bag: 0, Slot: slot}] = questTestItem(int32(slot), int32(slot), 1)
	}
	inv[constants.InventoryKey{Bag: 0, Slot: constants.SlotTrade1}] = questTestItem(100, 500, 1)

	assert.NoError(t, preflightQuestRewards(inv, nil, RewardSummary{}))
}

func TestPreflightRejectsReturnedGiveItemWhenInventoryAndCursorAreFull(t *testing.T) {
	inv := make(map[constants.InventoryKey]*constants.ItemWithInstance)
	for slot := constants.SlotGeneral1; slot <= constants.SlotGeneral8; slot++ {
		inv[constants.InventoryKey{Bag: 0, Slot: slot}] = questTestItem(int32(slot), int32(slot), 1)
	}
	inv[constants.InventoryKey{Bag: 0, Slot: constants.SlotCursor}] = questTestItem(200, 600, 1)
	inv[constants.InventoryKey{Bag: 0, Slot: constants.SlotTrade1}] = questTestItem(100, 500, 1)

	err := preflightQuestRewards(inv, nil, RewardSummary{})
	assert.EqualError(t, err, inventoryFullQuestMessage)
}

func TestPreflightRejectsWhenInventoryBecomesFullAfterItemWasStaged(t *testing.T) {
	// The offered item originally occupied General 1. After the player moves it
	// into the Give window, another item can fill General 1 before Give is
	// clicked. With every carried slot and the cursor now occupied, rejecting
	// the offer must fail preflight instead of consuming or stranding it.
	inv := make(map[constants.InventoryKey]*constants.ItemWithInstance)
	for slot := constants.SlotGeneral1; slot <= constants.SlotGeneral8; slot++ {
		inv[constants.InventoryKey{Bag: 0, Slot: slot}] = questTestItem(int32(slot), int32(1000+slot), 1)
	}
	inv[constants.InventoryKey{Bag: 0, Slot: constants.SlotCursor}] = questTestItem(200, 2000, 1)
	tradeKey := constants.InventoryKey{Bag: 0, Slot: constants.SlotTrade1}
	inv[tradeKey] = questTestItem(100, 500, 1)

	err := preflightQuestRewards(inv, nil, RewardSummary{})
	assert.EqualError(t, err, inventoryFullQuestMessage)
	assert.Equal(t, int32(500), inv[tradeKey].ItemInstanceID, "preflight must not mutate the staged item")
}

func TestPreflightUsesCursorWhenInventoryBecomesFullAfterItemWasStaged(t *testing.T) {
	// The same race remains recoverable when the cursor is free: it is the
	// deliberate final overflow slot for the returned Give-window item.
	inv := make(map[constants.InventoryKey]*constants.ItemWithInstance)
	for slot := constants.SlotGeneral1; slot <= constants.SlotGeneral8; slot++ {
		inv[constants.InventoryKey{Bag: 0, Slot: slot}] = questTestItem(int32(slot), int32(1000+slot), 1)
	}
	tradeKey := constants.InventoryKey{Bag: 0, Slot: constants.SlotTrade1}
	inv[tradeKey] = questTestItem(100, 500, 1)

	assert.NoError(t, preflightQuestRewards(inv, nil, RewardSummary{}))
	assert.Equal(t, int32(500), inv[tradeKey].ItemInstanceID, "preflight must remain non-mutating")
}

func TestBuildQuestSettlementInventoryPlansPartialConsumptionAndReturn(t *testing.T) {
	tradeKey := constants.InventoryKey{Bag: 0, Slot: constants.SlotTrade1}
	inv := map[constants.InventoryKey]*constants.ItemWithInstance{
		tradeKey: questTestItem(100, 500, 3),
	}
	plan := []questItemConsumption{{Key: tradeKey, ItemID: 100, Quantity: 2}}

	settlement, err := buildQuestSettlementInventory(inv, plan, RewardSummary{})
	require.NoError(t, err)
	returned := settlement.final[constants.InventoryKey{Bag: 0, Slot: constants.SlotGeneral1}]
	require.NotNil(t, returned)
	assert.Equal(t, uint8(1), returned.Instance.Quantity)
	assert.Equal(t, uint8(1), settlement.quantities[500])
	require.Len(t, settlement.moves, 1)
	assert.Equal(t, constants.SlotGeneral1, settlement.moves[0].to.Slot)
}

func TestRuntimeItemPlanDoesNotReturnUnrelatedGiveItems(t *testing.T) {
	key := constants.InventoryKey{Bag: 0, Slot: constants.SlotTrade1}
	inv := map[constants.InventoryKey]*constants.ItemWithInstance{key: questTestItem(100, 500, 3)}
	plan, err := buildQuestInventoryPlan(inv, nil, RewardSummary{}, false)
	require.NoError(t, err)
	require.Empty(t, plan.moves)
	require.Empty(t, plan.deleted)
	require.Empty(t, plan.quantities)
	require.Equal(t, inv, plan.final)
	require.NotSame(t, inv[key], plan.final[key], "Planning must not mutate live inventory")
}

func TestLocalQuestRewardCreationUsesFullChargesWithoutChangingReturnedInstance(t *testing.T) {
	if os.Getenv("IDLEQUEST_LOCAL_DB_AUDIT") != "true" {
		t.Skip("explicit local item-cache check")
	}
	_, err := dbitems.InitializeItemsMMF()
	require.NoError(t, err)
	returned := questTestItem(60001, 501, 1)
	returned.Instance.Charges = 2
	inv := map[constants.InventoryKey]*constants.ItemWithInstance{{Slot: constants.SlotTrade1}: returned}
	result, err := buildQuestSettlementInventory(inv, nil, RewardSummary{Items: []QuestReward{{ItemID: 5727, Count: 1}, {ItemID: 1001, Count: 1}}})
	require.NoError(t, err)
	charges := map[int32]uint8{}
	for _, item := range result.final {
		charges[item.Item.ID] = item.Instance.Charges
	}
	require.Equal(t, uint8(5), charges[5727], "Regal Band receives its five configured charges")
	require.Zero(t, charges[1001], "Ordinary equipment is not assigned an invented charge")
	require.Equal(t, uint8(2), charges[60001], "An unconsumed offer keeps its original charges")
	require.Equal(t, uint8(2), returned.Instance.Charges, "Planning never mutates the offered instance")
}

func TestCalculateQuestCurrencySettlementConsumesAndRewardsExactlyOnce(t *testing.T) {
	final, err := calculateQuestCurrencySettlement(
		QuestCurrency{Platinum: 10, Gold: 30, Silver: 5, Copper: 8},
		QuestCurrency{Platinum: 2, Gold: 3, Silver: 4, Copper: 5},
		QuestCurrency{Platinum: 1, Gold: 7, Silver: 2, Copper: 3},
	)
	require.NoError(t, err)
	assert.Equal(t, QuestCurrency{Platinum: 9, Gold: 34, Silver: 3, Copper: 6}, final)
}

func TestCalculateQuestCurrencySettlementRejectsUnavailableOffer(t *testing.T) {
	_, err := calculateQuestCurrencySettlement(
		QuestCurrency{Gold: 2},
		QuestCurrency{Gold: 3},
		QuestCurrency{},
	)
	assert.Error(t, err)
}

func TestValidateQuestRewardLoreRejectsExistingLoreGroup(t *testing.T) {
	existing := questTestItem(10604, 500, 1)
	existing.Item.Name = "Jeb's Seal"
	existing.Item.Loregroup = -1
	inventory := map[constants.InventoryKey]*constants.ItemWithInstance{
		{Bag: 0, Slot: constants.SlotGeneral1}: existing,
	}
	reward := model.Items{ID: 10604, Name: "Jeb's Seal", Loregroup: -1}

	err := validateQuestRewardLore(inventory, reward)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "Jeb's Seal")
}

func TestValidateQuestRewardLoreAllowsNonLoreDuplicate(t *testing.T) {
	existing := questTestItem(1001, 500, 1)
	existing.Item.Name = "Cloth Cap"
	inventory := map[constants.InventoryKey]*constants.ItemWithInstance{
		{Bag: 0, Slot: constants.SlotGeneral1}: existing,
	}
	reward := model.Items{ID: 1001, Name: "Cloth Cap"}

	require.NoError(t, validateQuestRewardLore(inventory, reward))
}

func TestValidateQuestRewardLoreAllowsDistinctIndividualLoreItems(t *testing.T) {
	existing := questTestItem(12764, 500, 1)
	existing.Item.Name = "Iksar Skull"
	existing.Item.Loregroup = -1
	inventory := map[constants.InventoryKey]*constants.ItemWithInstance{
		{Bag: 0, Slot: constants.SlotGeneral1}: existing,
	}
	reward := model.Items{ID: 12750, Name: "Iksar Skull", Loregroup: -1}

	// Individual lore items use -1 and may share a display name while still
	// being distinct quest rewards. Only the same item ID conflicts.
	require.NoError(t, validateQuestRewardLore(inventory, reward))
}

func TestRelocateQuestContainerContentsMovesEveryChildWithParent(t *testing.T) {
	parentSlot := constants.SlotTrade1
	childOne := questTestItem(100, 501, 1)
	childTwo := questTestItem(101, 502, 1)
	inventory := map[constants.InventoryKey]*constants.ItemWithInstance{
		{Bag: parentSlot + 1, Slot: 0}: childOne,
		{Bag: parentSlot + 1, Slot: 3}: childTwo,
	}

	moves := relocateQuestContainerContents(inventory, parentSlot, constants.SlotGeneral1)

	require.Len(t, moves, 2)
	require.NotContains(t, inventory, constants.InventoryKey{Bag: parentSlot + 1, Slot: 0})
	require.Same(t, childOne, inventory[constants.InventoryKey{Bag: constants.SlotGeneral1 + 1, Slot: 0}])
	require.Same(t, childTwo, inventory[constants.InventoryKey{Bag: constants.SlotGeneral1 + 1, Slot: 3}])
}

func TestApplyQuestInventorySlotUpdatesMovesContainerAndChildrenTogether(t *testing.T) {
	parent := questTestItem(17005, 500, 1)
	child := questTestItem(1001, 501, 1)
	inventory := map[constants.InventoryKey]*constants.ItemWithInstance{
		{Bag: 0, Slot: constants.SlotTrade1}:     parent,
		{Bag: constants.SlotTrade1 + 1, Slot: 0}: child,
	}

	applyQuestInventorySlotUpdates(inventory, []dbitems.SlotUpdate{
		{ItemInstanceID: 500, FromBag: 0, FromSlot: constants.SlotTrade1, ToBag: 0, ToSlot: constants.SlotGeneral1},
		{ItemInstanceID: 501, FromBag: constants.SlotTrade1 + 1, FromSlot: 0, ToBag: constants.SlotGeneral1 + 1, ToSlot: 0},
	})

	require.Same(t, parent, inventory[constants.InventoryKey{Bag: 0, Slot: constants.SlotGeneral1}])
	require.Same(t, child, inventory[constants.InventoryKey{Bag: constants.SlotGeneral1 + 1, Slot: 0}])
	require.NotContains(t, inventory, constants.InventoryKey{Bag: 0, Slot: constants.SlotTrade1})
	require.NotContains(t, inventory, constants.InventoryKey{Bag: constants.SlotTrade1 + 1, Slot: 0})
}
