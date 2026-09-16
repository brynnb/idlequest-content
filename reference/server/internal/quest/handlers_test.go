package quest

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestUnavailableQuestTemplateItemIDsChecksConsumedAndRewardItems(t *testing.T) {
	existing := map[int32]bool{
		1001: true,
		1002: true,
	}

	missing := unavailableQuestTemplateItemIDs(
		[]int{1001, 9001, 9001},
		RewardSummary{Items: []QuestReward{
			{ItemID: 1002, Count: 1},
			{ItemID: 9002, Count: 1},
			{ItemID: 9001, Count: 1},
		}},
		func(itemID int32) bool { return existing[itemID] },
	)

	assert.Equal(t, []int{9001, 9002}, missing)
}

func TestUnavailableQuestTemplateItemIDsIgnoresZeroAndCurrencyOnlyRewards(t *testing.T) {
	missing := unavailableQuestTemplateItemIDs(
		[]int{0},
		RewardSummary{Currency: QuestCurrency{Platinum: 1}},
		func(itemID int32) bool {
			t.Fatalf("exists should not be called for non-item quest effects, got %d", itemID)
			return false
		},
	)

	assert.Nil(t, missing)
}

func TestRejectUnavailableExpansionQuestItemsRejectsMissingRewardItem(t *testing.T) {
	response := rejectUnavailableExpansionQuestItems(
		[]int{1001},
		RewardSummary{Items: []QuestReward{{ItemID: 9001, Count: 1}}},
		func(itemID int32) bool { return itemID == 1001 },
	)

	assert.NotNil(t, response)
	assert.False(t, response.Success)
	assert.Equal(t, []int{9001}, response.UnavailableExpansionItemIDs)
	assert.Empty(t, response.Rewards.Items)
	assert.Empty(t, response.ConsumedItemIDs)
}

func TestRejectUnavailableExpansionQuestItemsRejectsMissingConsumedItem(t *testing.T) {
	response := rejectUnavailableExpansionQuestItems(
		[]int{9001},
		RewardSummary{Items: []QuestReward{{ItemID: 1001, Count: 1}}},
		func(itemID int32) bool { return itemID == 1001 },
	)

	assert.NotNil(t, response)
	assert.False(t, response.Success)
	assert.Equal(t, []int{9001}, response.UnavailableExpansionItemIDs)
}

func TestRejectUnavailableExpansionQuestItemsAllowsExistingItemsAndCurrencyRewards(t *testing.T) {
	response := rejectUnavailableExpansionQuestItems(
		[]int{1001},
		RewardSummary{
			Items:    []QuestReward{{ItemID: 1002, Count: 1}},
			Currency: QuestCurrency{Platinum: 1},
		},
		func(itemID int32) bool { return itemID == 1001 || itemID == 1002 },
	)

	assert.Nil(t, response)
}
