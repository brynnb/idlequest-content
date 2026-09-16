package quest

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestNormalizeLegacyTurnInCurrencySyntax(t *testing.T) {
	assert.Equal(t, `{item1 = 7, gold = 21}`, normalizeLegacyTurnInCurrencySyntax(`{item1 = 7, gold == 21}`))
	assert.Equal(t, `{gold = 10}`, normalizeLegacyTurnInCurrencySyntax(`{e.gold == 10}`))
	assert.Equal(t, `if gold == 10 then`, normalizeLegacyTurnInCurrencySyntax(`if gold == 10 then`))
	assert.Equal(t, `if e.other:GetClassName() == "Paladin" then`, normalizeLegacyTurnInCurrencySyntax(`if e.other:Class() == "Paladin" then`))
	assert.Equal(t, `if e.other:GetRaceName() == "Human" then`, normalizeLegacyTurnInCurrencySyntax(`if e.other:Race() == "Human" then`))
	assert.Equal(t, "local class = e.other:GetClassName()\nif class == \"Warrior\" then", normalizeLegacyTurnInCurrencySyntax("local class = e.other:Class()\nif class == \"Warrior\" then"))
}

func TestLegacyCurrencyRequirementActuallyConsumesCurrency(t *testing.T) {
	dataPath := t.TempDir()
	require.NoError(t, os.MkdirAll(filepath.Join(dataPath, "lua_modules"), 0o755))
	require.NoError(t, os.WriteFile(filepath.Join(dataPath, "lua_modules", "items.lua"), []byte(`
local items = {}
function items.check_turn_in(trade, required)
  return trade.self:CheckHandin(trade.other, {[13755]=1, gold=trade.gold}, {[13755]=1, gold=required.gold}, {trade.item1})
end
return items`), 0o600))
	bridge := NewLuaBridge(dataPath)
	capture, err := bridge.ExecuteTradeFromSource(`
function event_trade(e)
  local item_lib = require("items")
  if item_lib.check_turn_in(e.trade, {item1 = 13755, gold == 21}) then
    e.other:AddEXP(500)
  end
end`, &LuaEvent{NPC: &NPCProxy{}, Player: &PlayerProxy{}, Trade: &TradeProxy{Items: []int{13755}, Gold: 21}, Globals: map[string]string{}})
	require.NoError(t, err)
	assert.Equal(t, 500, capture.Exp)
	assert.Empty(t, capture.CurrentTrade.Items)
	assert.Zero(t, capture.CurrentTrade.Gold)
}
