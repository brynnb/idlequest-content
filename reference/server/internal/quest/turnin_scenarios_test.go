package quest

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestDiscoverTurnInScenarios(t *testing.T) {
	source := `
function event_trade(e)
  local item_lib = require("items")
  if item_lib.check_turn_in(e.trade, {
    item1 = 13916,
    item2 = 13916,
    gold = 2
  }) then
    e.other:Exp(100)
  end
  if item_lib.check_turn_in(e.trade, requirements) then end
end`

	discovery := DiscoverTurnInScenarios(source)
	require.Len(t, discovery.Scenarios, 1)
	assert.Equal(t, []int{13916, 13916}, discovery.Scenarios[0].Items)
	assert.Equal(t, 2, discovery.Scenarios[0].Currency.Gold)
	assert.Equal(t, 4, discovery.Scenarios[0].Line)
	require.Len(t, discovery.Unsupported, 1)
	assert.Contains(t, discovery.Unsupported[0].Reason, "not a literal table")
}

func TestDiscoveredTurnInExecutesThroughProductionLuaBridge(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	source := `
function event_trade(e)
  local item_lib = require("items")
  if item_lib.check_turn_in(e.trade, { item1 = 13916, platinum = 3 }) then
    e.self:Say("Accepted")
    e.other:SummonItem(13005)
    e.other:AddEXP(250)
  end
end`

	discovery := DiscoverTurnInScenarios(source)
	require.Len(t, discovery.Scenarios, 1)
	scenario := discovery.Scenarios[0]
	capture, err := NewLuaBridge(".").ExecuteTradeFromSource(source, &LuaEvent{
		NPC:     &NPCProxy{ID: 1, Name: "Test NPC"},
		Player:  &PlayerProxy{ID: 1, Name: "Questtester", CharClass: "Warrior", CharRace: "Human", CharLevel: 60},
		Trade:   &TradeProxy{Items: scenario.Items, Platinum: scenario.Currency.Platinum},
		Globals: map[string]string{},
	})
	require.NoError(t, err)
	assert.Contains(t, capture.Responses, "Accepted")
	assert.Equal(t, 250, capture.Exp)
	require.Len(t, capture.Items, 1)
	assert.Equal(t, 13005, capture.Items[0].ItemID)
	require.NotNil(t, capture.CurrentTrade)
	assert.Empty(t, capture.CurrentTrade.Items)
}

func TestDiscoverTurnInScenariosRejectsDynamicRequirements(t *testing.T) {
	source := `function event_trade(e)
  if item_lib.check_turn_in(e.trade, { item1 = required_item, gold = 2 }) then end
end`
	discovery := DiscoverTurnInScenarios(source)
	assert.Empty(t, discovery.Scenarios)
	require.Len(t, discovery.Unsupported, 1)
	assert.Contains(t, discovery.Unsupported[0].Reason, "dynamic expression")
}

func TestDiscoverTurnInScenariosExpandsConstantsAlternativesAndTableMembers(t *testing.T) {
	source := `
local card = 13906
local riddles = {{item=54068}, {item=54069}}
-- item_lib.check_turn_in(e.trade, {item1=999})
function event_trade(e)
  item_lib.check_turn_in(e.trade, {item1=card})
  item_lib.check_turn_in(e.trade, {item1=(18150 or 18151)})
  item_lib.check_turn_in(e.trade, {item1=riddle.item})
end`
	discovery := DiscoverTurnInScenarios(source)
	require.Empty(t, discovery.Unsupported)
	require.Len(t, discovery.Scenarios, 5)
	assert.Equal(t, []int{13906}, discovery.Scenarios[0].Items)
	assert.Equal(t, []int{18150}, discovery.Scenarios[1].Items)
	assert.Equal(t, []int{18151}, discovery.Scenarios[2].Items)
	assert.Equal(t, []int{54068}, discovery.Scenarios[3].Items)
	assert.Equal(t, []int{54069}, discovery.Scenarios[4].Items)
}
