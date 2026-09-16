package quest

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestLuaBridge_Say(t *testing.T) {
	bridge := NewLuaBridge(".")

	// Create a dummy script
	script := `
	function event_say(e)
		if e.message:findi("hail") then
			e.self:Say("Welcome to Norrath, " .. e.other:GetName() .. "!")
		elseif e.message:findi("rule") then
			e.self:Say("I rule this town!")
		end
	end
	`
	tmpfile, err := os.CreateTemp("", "quest_*.lua")
	if err != nil {
		t.Fatal(err)
	}
	defer os.Remove(tmpfile.Name())

	if _, err := tmpfile.Write([]byte(script)); err != nil {
		t.Fatal(err)
	}
	tmpfile.Close()

	// Test Hail
	event := &LuaEvent{
		NPC:     &NPCProxy{Name: "Guard Jup"},
		Player:  &PlayerProxy{Name: "Vayoen", CharClass: "Warrior", CharLevel: 1},
		Message: "hail",
	}

	capture, err := bridge.ExecuteSay(tmpfile.Name(), event)
	assert.NoError(t, err)
	assert.Contains(t, capture.Responses, "Welcome to Norrath, Vayoen!")

	// Test Rule
	event.Message = "rule"
	capture, err = bridge.ExecuteSay(tmpfile.Name(), event)
	assert.NoError(t, err)
	assert.Contains(t, capture.Responses, "I rule this town!")
}

func TestLuaBridge_Trade(t *testing.T) {
	bridge := NewLuaBridge(".")

	script := `
	function event_trade(e)
		local item_lib = require("items")
		if item_lib.check_turn_in(e.trade, {item1 = 13005}) then
			e.self:Say("Thank you for the item!")
		end
	end
	`
	// Since we require("items"), we need the lua_modules directory
	os.MkdirAll("lua_modules", 0755)
	os.WriteFile("lua_modules/items.lua", []byte(`
	local M = {}
	function M.check_turn_in(trade, req)
		if trade.item1 and trade.item1:GetID() == req.item1 then
			return true
		end
		return false
	end
	return M
	`), 0644)
	defer os.RemoveAll("lua_modules")

	tmpfile, _ := os.CreateTemp("", "quest_*.lua")
	defer os.Remove(tmpfile.Name())
	tmpfile.Write([]byte(script))
	tmpfile.Close()

	event := &LuaEvent{
		NPC:    &NPCProxy{Name: "Trader"},
		Player: &PlayerProxy{Name: "Vayoen"},
		Trade:  &TradeProxy{Items: []int{13005}},
	}

	capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
	assert.NoError(t, err)
	assert.Contains(t, capture.Responses, "Thank you for the item!")
}

// TestLuaBridge_TradeRealItemsLua exercises the REAL items.lua check_turn_in → CheckHandin flow.
// This is the path that was broken: items.lua builds {[item_id]=count} tables and calls
// trade.self:CheckHandin(trade.other, handin_data, required_data, item_data).
func TestLuaBridge_TradeRealItemsLua(t *testing.T) {
	bridge := NewLuaBridge(".")

	// Use the real items.lua from the quest data
	realItemsLua := `
local items = {}

function items.check_turn_in(trade, trade_check)
    local handin_data = {};
    local index = 1;
    for key, value in pairs(trade) do
        if type(key) == "string" and key:findi("item") then
            local item_id = value:GetID()
            if item_id ~= nil and item_id ~= 0 then
                if handin_data[item_id] ~= nil then
                    handin_data[item_id] = handin_data[item_id] + 1
                else
                    handin_data[item_id] = 1
                end
            end
        end
    end

    local item_data = {};
    for x = 1, 4 do
        local inst = trade["item" .. x];
        if (inst.valid) then
            item_data[x] = inst
        end
    end

    local required_data = {}
    for i = 1, 4 do
        local key = "item" .. i;
        local item_id = trade_check[key]
        if item_id ~= nil and item_id ~= 0 then
            if required_data[item_id] ~= nil then
                required_data[item_id] = required_data[item_id] + 1
            else
                required_data[item_id] = 1
            end
        end
    end

    local currencies = { "platinum", "gold", "silver", "copper" }
    for _, currency in ipairs(currencies) do
        if trade_check[currency] ~= nil and trade_check[currency] ~= 0 then
            required_data[currency] = trade_check[currency]
        end
    end
    for _, currency in ipairs(currencies) do
        if trade[currency] ~= nil and trade[currency] ~= 0 then
            handin_data[currency] = trade[currency]
        end
    end

    if (trade.self) then
        return trade.self:CheckHandin(trade.other, handin_data, required_data, item_data);
    else
        return false
    end
end

function items.return_items(npc, client, trade, text)
    npc:ReturnHandinItems(client);
end

return items
`

	os.MkdirAll("lua_modules", 0755)
	defer os.RemoveAll("lua_modules")
	os.WriteFile("lua_modules/items.lua", []byte(realItemsLua), 0644)

	t.Run("single item turn-in succeeds", func(t *testing.T) {
		script := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {item1 = 13005}) then
				e.self:Say("Thanks!")
			else
				e.self:Say("I don't need this.")
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Trader"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{13005}},
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Contains(t, capture.Responses, "Thanks!")
	})

	t.Run("duplicate item turn-in succeeds (Deathfist Belts scenario)", func(t *testing.T) {
		script := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {item1 = 13916, item2 = 13916}) then
				e.self:Say("Well done!")
			else
				e.self:Say("I have no use for these.")
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Captain_Hazran"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{13916, 13916}},
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Contains(t, capture.Responses, "Well done!")
	})

	t.Run("wrong item is rejected", func(t *testing.T) {
		script := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {item1 = 13916}) then
				e.self:Say("Accepted!")
			else
				e.self:Say("Rejected!")
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Captain_Hazran"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{99999}},
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Contains(t, capture.Responses, "Rejected!")
	})

	t.Run("too few items is rejected", func(t *testing.T) {
		script := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {item1 = 13916, item2 = 13916}) then
				e.self:Say("Accepted!")
			else
				e.self:Say("Rejected!")
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Captain_Hazran"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{13916}},
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Contains(t, capture.Responses, "Rejected!")
	})
}

func TestLuaBridge_EQHandin(t *testing.T) {
	bridge := NewLuaBridge(".")

	t.Run("direct helper consumes matching items once", func(t *testing.T) {
		script := `
		function event_trade(e)
			if eq.handin({[28027] = 1, [28028] = 1, [28029] = 1, [28030] = 1}) then
				e.self:Say("Words of Mastery")
				e.other:SummonItem(28004)
			else
				e.self:Say("No")
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		trade := &TradeProxy{Items: []int{28027, 28028, 28029, 28030}}
		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Akksstaff"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  trade,
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Contains(t, capture.Responses, "Words of Mastery")
		assert.Equal(t, []QuestReward{{ItemID: 28004, Count: 1}}, capture.Items)
		assert.Empty(t, trade.Items)
	})

	t.Run("failed branch does not consume before later matching branch", func(t *testing.T) {
		script := `
		function event_trade(e)
			if eq.handin({[1] = 1, [2] = 1}) then
				e.self:Say("wrong")
			elseif eq.handin({[3] = 1, gold = 50}) then
				e.self:Say("right")
			else
				e.self:Say("no")
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		trade := &TradeProxy{Items: []int{3}, Gold: 50}
		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Trader"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  trade,
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Contains(t, capture.Responses, "right")
		assert.Empty(t, trade.Items)
		assert.Equal(t, 0, trade.Gold)
	})
}

// =============================================================================
// Quest Reward Capture Tests
// =============================================================================

// TestLuaBridge_CurrencyRewards verifies that GiveCash captures currency rewards.
// Real example: many quests reward copper/silver/gold/platinum via e.other:GiveCash.
func TestLuaBridge_CurrencyRewards(t *testing.T) {
	bridge := NewLuaBridge(".")

	setupRealItemsLua(t)
	defer os.RemoveAll("lua_modules")

	t.Run("GiveCash captures all denominations", func(t *testing.T) {
		// Simulates a quest like Freeport Militia where you turn in belts for coin
		script := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {item1 = 13916}) then
				e.self:Say("Good work, soldier!")
				e.other:GiveCash(50, 3, 1, 0)  -- 50 copper, 3 silver, 1 gold, 0 plat
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Captain_Hazran"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{13916}},
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Contains(t, capture.Responses, "Good work, soldier!")
		assert.Equal(t, 50, capture.Currency.Copper)
		assert.Equal(t, 3, capture.Currency.Silver)
		assert.Equal(t, 1, capture.Currency.Gold)
		assert.Equal(t, 0, capture.Currency.Platinum)
	})

	t.Run("GiveCash with platinum", func(t *testing.T) {
		script := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {item1 = 13005}) then
				e.self:Say("A generous reward!")
				e.other:GiveCash(0, 0, 5, 10)  -- 0 copper, 0 silver, 5 gold, 10 plat
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Trader"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{13005}},
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Equal(t, 0, capture.Currency.Copper)
		assert.Equal(t, 0, capture.Currency.Silver)
		assert.Equal(t, 5, capture.Currency.Gold)
		assert.Equal(t, 10, capture.Currency.Platinum)
	})

	t.Run("no currency when turn-in fails", func(t *testing.T) {
		script := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {item1 = 13005}) then
				e.other:GiveCash(100, 0, 0, 0)
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Trader"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{99999}}, // Wrong item
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Equal(t, 0, capture.Currency.Copper)
		assert.Equal(t, 0, capture.Currency.Silver)
		assert.Equal(t, 0, capture.Currency.Gold)
		assert.Equal(t, 0, capture.Currency.Platinum)
	})
}

// TestLuaBridge_FactionRewards verifies that Faction/RewardFaction captures faction changes.
func TestLuaBridge_FactionRewards(t *testing.T) {
	bridge := NewLuaBridge(".")

	setupRealItemsLua(t)
	defer os.RemoveAll("lua_modules")

	t.Run("positive and negative faction adjustments", func(t *testing.T) {
		// Simulates turning in Deathfist Slashed Belts to Captain Hazran
		// Real quest: improves Militia (faction 265) and worsens Deathfist (faction 262)
		script := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {item1 = 13916}) then
				e.self:Say("Good work!")
				e.other:Faction(265, 10)   -- Militia gets better
				e.other:Faction(262, -10)  -- Deathfist gets worse
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Captain_Hazran"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{13916}},
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Len(t, capture.Factions, 2)
		assert.Equal(t, 265, capture.Factions[0].FactionID)
		assert.Equal(t, 10, capture.Factions[0].Amount)
		assert.Equal(t, 262, capture.Factions[1].FactionID)
		assert.Equal(t, -10, capture.Factions[1].Amount)
	})

	t.Run("RewardFaction alias works", func(t *testing.T) {
		script := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {item1 = 13005}) then
				e.other:RewardFaction(100, 5)
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Trader"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{13005}},
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Len(t, capture.Factions, 1)
		assert.Equal(t, 100, capture.Factions[0].FactionID)
		assert.Equal(t, 5, capture.Factions[0].Amount)
	})

	t.Run("no factions when turn-in fails", func(t *testing.T) {
		script := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {item1 = 13005}) then
				e.other:Faction(100, 5)
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Trader"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{99999}},
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Len(t, capture.Factions, 0)
	})
}

// TestLuaBridge_ItemRewards verifies that SummonItem captures item rewards.
func TestLuaBridge_ItemRewards(t *testing.T) {
	bridge := NewLuaBridge(".")

	setupRealItemsLua(t)
	defer os.RemoveAll("lua_modules")

	t.Run("single item reward", func(t *testing.T) {
		script := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {item1 = 13916}) then
				e.self:Say("Here is your reward!")
				e.other:SummonItem(12345)
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Captain_Hazran"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{13916}},
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Len(t, capture.Items, 1)
		assert.Equal(t, 12345, capture.Items[0].ItemID)
		assert.Equal(t, 1, capture.Items[0].Count)
	})

	t.Run("item reward with quantity", func(t *testing.T) {
		script := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {item1 = 13005}) then
				e.other:SummonItem(5001, 3)
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Trader"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{13005}},
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Len(t, capture.Items, 1)
		assert.Equal(t, 5001, capture.Items[0].ItemID)
		assert.Equal(t, 3, capture.Items[0].Count)
	})

	t.Run("multiple item rewards", func(t *testing.T) {
		script := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {item1 = 13005}) then
				e.other:SummonItem(5001)
				e.other:SummonItem(5002)
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Trader"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{13005}},
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Len(t, capture.Items, 2)
		assert.Equal(t, 5001, capture.Items[0].ItemID)
		assert.Equal(t, 5002, capture.Items[1].ItemID)
	})
}

// TestLuaBridge_ExperienceRewards verifies that AddEXP captures experience rewards.
func TestLuaBridge_ExperienceRewards(t *testing.T) {
	bridge := NewLuaBridge(".")

	setupRealItemsLua(t)
	defer os.RemoveAll("lua_modules")

	t.Run("experience reward", func(t *testing.T) {
		script := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {item1 = 13916}) then
				e.self:Say("Well done!")
				e.other:AddEXP(500)
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Captain_Hazran"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{13916}},
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Equal(t, 500, capture.Exp)
	})

	t.Run("ding flag captured", func(t *testing.T) {
		script := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {item1 = 13005}) then
				e.other:AddEXP(10000)
				e.other:Ding()
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Trader"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{13005}},
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Equal(t, 10000, capture.Exp)
		assert.True(t, capture.Ding)
	})

	t.Run("level based reward uses the player's P99 progression requirement", func(t *testing.T) {
		script := `
		function event_trade(e)
			e.other:AddLevelBasedExp(10, 0)
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		_, _ = tmpfile.Write([]byte(script))
		_ = tmpfile.Close()

		capture, err := bridge.ExecuteTrade(tmpfile.Name(), &LuaEvent{
			NPC:    &NPCProxy{Name: "Trainer"},
			Player: &PlayerProxy{Name: "Tank", CharLevel: 20, RaceID: 9, ClassID: 1},
			Trade:  &TradeProxy{},
		})
		assert.NoError(t, err)
		assert.Equal(t, 123228, capture.Exp)
	})
}

// TestLuaBridge_ConsumedCurrencyTracking verifies that consumed currency is
// correctly tracked via CurrentTrade after a turn-in.
func TestLuaBridge_ConsumedCurrencyTracking(t *testing.T) {
	bridge := NewLuaBridge(".")

	setupRealItemsLua(t)
	defer os.RemoveAll("lua_modules")

	t.Run("currency consumed when required by quest", func(t *testing.T) {
		// Quest requires 5 gold: trade sends 5 gold, check_turn_in requires gold=5
		script := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {gold = 5}) then
				e.self:Say("Payment received!")
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Merchant"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{}, Gold: 5},
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Contains(t, capture.Responses, "Payment received!")
		// CurrentTrade should reflect remaining trade state after consumption
		assert.NotNil(t, capture.CurrentTrade)
	})

	t.Run("currency not consumed when quest fails", func(t *testing.T) {
		script := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {item1 = 13005, gold = 5}) then
				e.self:Say("Accepted!")
			else
				e.self:Say("I need the right item AND gold!")
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		// Send gold but wrong item
		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Merchant"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{99999}, Gold: 5},
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Contains(t, capture.Responses, "I need the right item AND gold!")
	})
}

func TestNPCAddItemCapturesRuntimeLoot(t *testing.T) {
	bridge := NewLuaBridge(".")
	capture, err := bridge.ExecuteEventFromSource(`
function event_trade(e)
  e.self:AddItem(18099, 1)
end
`, "event_trade", &LuaEvent{
		NPC:    &NPCProxy{ID: 93083, Name: "Kurron Ni"},
		Player: &PlayerProxy{Name: "Shadowknight"},
		Trade:  &TradeProxy{},
	})
	assert.NoError(t, err)
	assert.Equal(t, []NPCAddedLoot{{NPCID: 93083, ItemID: 18099, Count: 1}}, capture.NPCAddedLoot)
	stored, err := NPCAddedLootFromScriptState(capture.ScriptState)
	assert.NoError(t, err)
	assert.Equal(t, []NPCAddedLoot{{NPCID: 93083, ItemID: 18099, Count: 1}}, stored)
}

func TestNPCAddItemPreservesExistingRuntimeLootState(t *testing.T) {
	bridge := NewLuaBridge(".")
	existing := NPCAddedLoot{NPCID: 93083, ItemID: 18099, Count: 1}
	capture, err := bridge.ExecuteEventFromSource(`
function event_trade(e)
  e.self:AddItem(18100, 2)
end
`, "event_trade", &LuaEvent{
		NPC:         &NPCProxy{ID: 93083, Name: "Kurron Ni"},
		Player:      &PlayerProxy{Name: "Shadowknight"},
		Trade:       &TradeProxy{},
		ScriptState: map[string]any{NPCAddedLootScriptStateKey: []NPCAddedLoot{existing}},
	})
	assert.NoError(t, err)
	assert.Equal(t, []NPCAddedLoot{{NPCID: 93083, ItemID: 18100, Count: 2}}, capture.NPCAddedLoot)
	stored, err := NPCAddedLootFromScriptState(capture.ScriptState)
	assert.NoError(t, err)
	assert.Equal(t, []NPCAddedLoot{
		existing,
		{NPCID: 93083, ItemID: 18100, Count: 2},
	}, stored)
}

// TestLuaBridge_CombinedRewards verifies a realistic quest that gives items, cash,
// faction, and exp all together.
func TestLuaBridge_CombinedRewards(t *testing.T) {
	bridge := NewLuaBridge(".")

	setupRealItemsLua(t)
	defer os.RemoveAll("lua_modules")

	// Realistic quest: turn in 2 items, receive item reward, cash, faction, and exp
	script := `
	function event_trade(e)
		local item_lib = require("items")
		if item_lib.check_turn_in(e.trade, {item1 = 13916, item2 = 13916}) then
			e.self:Say("Excellent work! The Militia thanks you.")
			e.other:SummonItem(12345)           -- reward item
			e.other:GiveCash(0, 5, 2, 1)        -- 0 copper, 5 silver, 2 gold, 1 plat
			e.other:Faction(265, 10)             -- Militia better
			e.other:Faction(262, -5)             -- Deathfist worse
			e.other:AddEXP(1000)
		end
	end
	`
	tmpfile, _ := os.CreateTemp("", "quest_*.lua")
	defer os.Remove(tmpfile.Name())
	tmpfile.Write([]byte(script))
	tmpfile.Close()

	event := &LuaEvent{
		NPC:    &NPCProxy{Name: "Captain_Hazran"},
		Player: &PlayerProxy{Name: "Vayoen"},
		Trade:  &TradeProxy{Items: []int{13916, 13916}},
	}
	capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
	assert.NoError(t, err)

	// NPC response
	assert.Contains(t, capture.Responses, "Excellent work! The Militia thanks you.")

	// Item reward
	assert.Len(t, capture.Items, 1)
	assert.Equal(t, 12345, capture.Items[0].ItemID)

	// Currency reward
	assert.Equal(t, 0, capture.Currency.Copper)
	assert.Equal(t, 5, capture.Currency.Silver)
	assert.Equal(t, 2, capture.Currency.Gold)
	assert.Equal(t, 1, capture.Currency.Platinum)

	// Faction rewards
	assert.Len(t, capture.Factions, 2)
	assert.Equal(t, 265, capture.Factions[0].FactionID)
	assert.Equal(t, 10, capture.Factions[0].Amount)
	assert.Equal(t, 262, capture.Factions[1].FactionID)
	assert.Equal(t, -5, capture.Factions[1].Amount)

	// Experience reward
	assert.Equal(t, 1000, capture.Exp)
}

// TestLuaBridge_CurrencyOnlyTurnIn verifies quests that require only currency (no items).
func TestLuaBridge_CurrencyOnlyTurnIn(t *testing.T) {
	bridge := NewLuaBridge(".")

	setupRealItemsLua(t)
	defer os.RemoveAll("lua_modules")

	t.Run("platinum only requirement", func(t *testing.T) {
		script := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {platinum = 10}) then
				e.self:Say("Thank you for the donation!")
				e.other:SummonItem(9999)
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Priest"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{}, Platinum: 10},
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Contains(t, capture.Responses, "Thank you for the donation!")
		assert.Len(t, capture.Items, 1)
		assert.Equal(t, 9999, capture.Items[0].ItemID)
	})

	t.Run("insufficient platinum rejected", func(t *testing.T) {
		script := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {platinum = 10}) then
				e.self:Say("Accepted!")
			else
				e.self:Say("I need 10 platinum!")
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Priest"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{}, Platinum: 5},
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Contains(t, capture.Responses, "I need 10 platinum!")
	})
}

// TestLuaBridge_ItemAndCurrencyTurnIn verifies quests requiring both items and currency.
func TestLuaBridge_ItemAndCurrencyTurnIn(t *testing.T) {
	bridge := NewLuaBridge(".")

	setupRealItemsLua(t)
	defer os.RemoveAll("lua_modules")

	t.Run("item plus currency succeeds", func(t *testing.T) {
		script := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {item1 = 13005, gold = 2}) then
				e.self:Say("Item and gold received!")
				e.other:GiveCash(0, 0, 0, 5) -- 5 plat reward
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Merchant"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{13005}, Gold: 2},
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Contains(t, capture.Responses, "Item and gold received!")
		assert.Equal(t, 5, capture.Currency.Platinum)
	})

	t.Run("item correct but currency insufficient rejected", func(t *testing.T) {
		script := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {item1 = 13005, gold = 10}) then
				e.self:Say("Accepted!")
			else
				e.self:Say("I need more gold!")
			end
		end
		`
		tmpfile, _ := os.CreateTemp("", "quest_*.lua")
		defer os.Remove(tmpfile.Name())
		tmpfile.Write([]byte(script))
		tmpfile.Close()

		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "Merchant"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{13005}, Gold: 5},
		}
		capture, err := bridge.ExecuteTrade(tmpfile.Name(), event)
		assert.NoError(t, err)
		assert.Contains(t, capture.Responses, "I need more gold!")
	})
}

// TestLuaBridge_ExecuteFromSource verifies quest execution from DB source strings
// (the path used in production — no file, just Lua source text).
func TestLuaBridge_ExecuteFromSource(t *testing.T) {
	bridge := NewLuaBridge(".")

	setupRealItemsLua(t)
	defer os.RemoveAll("lua_modules")

	t.Run("trade from source with all rewards", func(t *testing.T) {
		source := `
		function event_trade(e)
			local item_lib = require("items")
			if item_lib.check_turn_in(e.trade, {item1 = 13916}) then
				e.self:Say("Source-based quest works!")
				e.other:GiveCash(10, 0, 0, 0)
				e.other:Faction(100, 3)
				e.other:AddEXP(200)
			end
		end
		`
		event := &LuaEvent{
			NPC:    &NPCProxy{Name: "TestNPC"},
			Player: &PlayerProxy{Name: "Vayoen"},
			Trade:  &TradeProxy{Items: []int{13916}},
		}
		capture, err := bridge.ExecuteTradeFromSource(source, event)
		assert.NoError(t, err)
		assert.Contains(t, capture.Responses, "Source-based quest works!")
		assert.Equal(t, 10, capture.Currency.Copper)
		assert.Len(t, capture.Factions, 1)
		assert.Equal(t, 200, capture.Exp)
	})

	t.Run("say from source", func(t *testing.T) {
		source := `
		function event_say(e)
			if e.message:findi("hail") then
				e.self:Say("Hello, " .. e.other:GetName() .. "!")
			end
		end
		`
		event := &LuaEvent{
			NPC:     &NPCProxy{Name: "Guard"},
			Player:  &PlayerProxy{Name: "Vayoen"},
			Message: "hail",
		}
		capture, err := bridge.ExecuteSayFromSource(source, event)
		assert.NoError(t, err)
		assert.Contains(t, capture.Responses, "Hello, Vayoen!")
	})
}

func TestLuaBridge_TradeCapturesSpawnRequests(t *testing.T) {
	bridge := NewLuaBridge(".")
	source := `
	function event_trade(e)
		eq.spawn2(123, 7, 0, e.self:GetX() + 1, e.self:GetY() + 2, e.self:GetZ() + 3, e.self:GetHeading() + 4)
		local spawned = eq.unique_spawn(456, 8, 0, 10, 20, 30, 40)
		spawned:CastToNPC():MoveTo(11, 22, 33, 44, true)
	end
	`

	event := &LuaEvent{
		NPC: &NPCProxy{
			Name:    "Spawner",
			X:       100,
			Y:       200,
			Z:       300,
			Heading: 50,
		},
		Player: &PlayerProxy{Name: "Vayoen"},
		Trade:  &TradeProxy{Items: []int{13005}},
	}

	capture, err := bridge.ExecuteTradeFromSource(source, event)
	assert.NoError(t, err)
	if assert.Len(t, capture.Spawns, 2) {
		assert.Equal(t, QuestSpawnRequest{
			NPCTypeID: 123,
			GridID:    7,
			X:         101,
			Y:         202,
			Z:         303,
			Heading:   54,
			Unique:    false,
		}, capture.Spawns[0])
		assert.Equal(t, QuestSpawnRequest{
			NPCTypeID: 456,
			GridID:    8,
			X:         10,
			Y:         20,
			Z:         30,
			Heading:   40,
			Unique:    true,
		}, capture.Spawns[1])
	}
}

func TestLuaBridge_SetSkillCapturesSkillUpdate(t *testing.T) {
	bridge := NewLuaBridge(".")
	source := `
	function event_trade(e)
		e.other:SetSkill(43, 49)
	end
	`

	capture, err := bridge.ExecuteEventFromSource(source, "event_trade", &LuaEvent{
		NPC:     &NPCProxy{Name: "Ostorm"},
		Player:  &PlayerProxy{Name: "Caster", Tasks: map[int]bool{}},
		Globals: map[string]string{},
		Trade:   &TradeProxy{},
	})

	assert.NoError(t, err)
	assert.Equal(t, []QuestSkillUpdate{{SkillID: 43, Value: 49}}, capture.SkillUpdates)
}

func TestLuaBridge_TradeCapturesZoneFlagRequests(t *testing.T) {
	bridge := NewLuaBridge(".")
	source := `
	function event_trade(e)
		eq.set_zone_flag(105)
	end
	`

	capture, err := bridge.ExecuteTradeFromSource(source, &LuaEvent{
		NPC:    &NPCProxy{Name: "Flagger"},
		Player: &PlayerProxy{Name: "Vayoen"},
		Trade:  &TradeProxy{Items: []int{20600}},
	})
	assert.NoError(t, err)
	assert.Equal(t, []int{105}, capture.ZoneFlags)
}

func TestLuaBridge_RogueEpicKithicorSealedBoxSpawn(t *testing.T) {
	setupRealItemsLua(t)
	bridge := NewLuaBridge(".")
	source := `
	function event_trade(e)
		local item_lib = require("items")

		if item_lib.check_turn_in(e.trade, {item1 = 28057}) then
			e.self:Say("The General will take care of you!")
			e.other:Ding()
			e.other:AddEXP(500)
			eq.spawn2(20205, 0, 0, 2316, 797, 275, 387)
		end

		item_lib.return_items(e.self, e.other, e.trade)
	end
	`

	capture, err := bridge.ExecuteTradeFromSource(source, &LuaEvent{
		NPC:    &NPCProxy{Name: "Tasi V`ghera"},
		Player: &PlayerProxy{Name: "Vayoen"},
		Trade:  &TradeProxy{Items: []int{28057}},
	})

	assert.NoError(t, err)
	assert.Contains(t, capture.Responses, "The General will take care of you!")
	assert.True(t, capture.Ding)
	assert.Equal(t, 500, capture.Exp)
	if assert.Len(t, capture.Spawns, 1) {
		assert.Equal(t, int32(20205), capture.Spawns[0].NPCTypeID)
		assert.Equal(t, float64(2316), capture.Spawns[0].X)
		assert.Equal(t, float64(797), capture.Spawns[0].Y)
		assert.Equal(t, float64(275), capture.Spawns[0].Z)
		assert.Equal(t, float64(387), capture.Spawns[0].Heading)
	}
}

func TestLuaBridgeCapturesHPAndProximityRegistration(t *testing.T) {
	bridge := NewLuaBridge(".")
	capture, err := bridge.ExecuteEventFromSource(`
function event_spawn(e)
  eq.set_next_hp_event(75)
  eq.set_next_inc_hp_event(90)
  eq.set_proximity(1, 2, 3, 4, 5, 6)
end`, "event_spawn", &LuaEvent{NPC: &NPCProxy{ID: 1}, Player: &PlayerProxy{ID: 2}})
	assert.NoError(t, err)
	assert.Equal(t, []HPEventUpdate{{Percent: 75}, {Percent: 90, Increasing: true}}, capture.HPEvents)
	assert.Equal(t, &ProximityUpdate{MinX: 1, MaxX: 2, MinY: 3, MaxY: 4, MinZ: 5, MaxZ: 6}, capture.Proximity)
}

func TestLuaBridgeCapturesTwoDimensionalAndClearedProximity(t *testing.T) {
	bridge := NewLuaBridge(".")
	capture, err := bridge.ExecuteEventFromSource(`
function event_spawn(e)
  eq.set_proximity(-10, 10, -20, 20)
end`, "event_spawn", &LuaEvent{NPC: &NPCProxy{ID: 1}, Player: &PlayerProxy{ID: 2}})
	assert.NoError(t, err)
	assert.Equal(t, -1000000.0, capture.Proximity.MinZ)
	assert.Equal(t, 1000000.0, capture.Proximity.MaxZ)

	capture, err = bridge.ExecuteEventFromSource(`function event_spawn(e) eq.clear_proximity() end`, "event_spawn", &LuaEvent{NPC: &NPCProxy{ID: 1}, Player: &PlayerProxy{ID: 2}})
	assert.NoError(t, err)
	assert.True(t, capture.Proximity.Clear)
}

func TestLuaBridgeCreateGroundObjectCapturesEQEmuSemantics(t *testing.T) {
	bridge := NewLuaBridge(".")
	capture, err := bridge.ExecuteEventFromSource(`
		function event_spawn(e)
			local first = eq.create_ground_object(12147, -627, 148, -61, 32)
			local second = eq.create_ground_object(67705, -537, -620, -5, 2, 3600000)
			if first ~= 1 or second ~= 2 then error("unexpected runtime object id") end
		end
	`, "event_spawn", &LuaEvent{NPC: &NPCProxy{ID: 1}, Player: &PlayerProxy{ID: 2}})
	assert.NoError(t, err)
	if assert.Len(t, capture.GroundItems, 2) {
		assert.Equal(t, QuestGroundObjectRequest{
			RuntimeID: 1, ItemID: 12147, X: -627, Y: 148, Z: -61, Heading: 32, DecayMS: 300000,
		}, capture.GroundItems[0])
		assert.Equal(t, QuestGroundObjectRequest{
			RuntimeID: 2, ItemID: 67705, X: -537, Y: -620, Z: -5, Heading: 2, DecayMS: 3600000,
		}, capture.GroundItems[1])
	}
}

func TestLuaBridgeMathRandomVariesAcrossFreshEventStates(t *testing.T) {
	bridge := NewLuaBridge(".")
	source := `
		function event_death_complete(e)
			local roll = math.random(100)
			if roll <= 15 then
				eq.unique_spawn(90184, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
			else
				eq.spawn2(90192, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
			end
		end
	`

	seenRareSpawn := false
	seenCommonSpawn := false
	for i := 0; i < 200; i++ {
		capture, err := bridge.ExecuteEventFromSource(source, "event_death_complete", &LuaEvent{
			NPC:             &NPCProxy{ID: 90192, Name: "a_black_reaver", X: 1, Y: 2, Z: 3, Heading: 4},
			Player:          &PlayerProxy{ID: 7, Name: "Tester", Tasks: map[int]bool{}},
			Globals:         map[string]string{},
			Fields:          map[string]any{},
			SpawnInstanceID: int64(1000 + i),
		})
		assert.NoError(t, err)
		if !assert.Len(t, capture.Spawns, 1) {
			continue
		}
		switch capture.Spawns[0].NPCTypeID {
		case 90184:
			seenRareSpawn = true
		case 90192:
			seenCommonSpawn = true
		default:
			t.Fatalf("unexpected spawned npc type %d", capture.Spawns[0].NPCTypeID)
		}
		if seenRareSpawn && seenCommonSpawn {
			return
		}
	}

	assert.True(t, seenRareSpawn, "expected Lua math.random rare spawn branch to be reachable across fresh event states")
	assert.True(t, seenCommonSpawn, "expected Lua math.random common spawn branch to remain reachable")
}

func TestLuaBridgeRestoresLocalUpvalueAcrossDifferentEventHandlers(t *testing.T) {
	bridge := NewLuaBridge(".")
	source := `
		local spawn_trakanon = false

		function event_trade(e)
			spawn_trakanon = true
		end

		function event_death_complete(e)
			if spawn_trakanon then
				eq.spawn2(89181, 0, 0, -693, -2103, -140.62, 0)
				spawn_trakanon = false
			end
		end
	`

	tradeCapture, err := bridge.ExecuteEventFromSource(source, "event_trade", &LuaEvent{
		NPC:     &NPCProxy{ID: 89168, Name: "An_Undead_Bard"},
		Player:  &PlayerProxy{ID: 7, Name: "Tester", Tasks: map[int]bool{}},
		Globals: map[string]string{},
	})
	assert.NoError(t, err)
	assert.Equal(t, true, tradeCapture.ScriptState["upvalue:spawn_trakanon"])

	deathCapture, err := bridge.ExecuteEventFromSource(source, "event_death_complete", &LuaEvent{
		NPC:             &NPCProxy{ID: 89168, Name: "An_Undead_Bard"},
		Player:          &PlayerProxy{ID: 7, Name: "Tester", Tasks: map[int]bool{}},
		Globals:         map[string]string{},
		ScriptState:     tradeCapture.ScriptState,
		SpawnInstanceID: 5001,
	})
	assert.NoError(t, err)
	if assert.Len(t, deathCapture.Spawns, 1) {
		assert.Equal(t, int32(89181), deathCapture.Spawns[0].NPCTypeID)
	}
	assert.Equal(t, false, deathCapture.ScriptState["upvalue:spawn_trakanon"])
}

// setupRealItemsLua writes a realistic items.lua module for tests.
func setupRealItemsLua(t *testing.T) {
	t.Helper()
	realItemsLua := `
local items = {}

function items.check_turn_in(trade, trade_check)
    local handin_data = {};
    local index = 1;
    for key, value in pairs(trade) do
        if type(key) == "string" and key:findi("item") then
            local item_id = value:GetID()
            if item_id ~= nil and item_id ~= 0 then
                if handin_data[item_id] ~= nil then
                    handin_data[item_id] = handin_data[item_id] + 1
                else
                    handin_data[item_id] = 1
                end
            end
        end
    end

    local item_data = {};
    for x = 1, 4 do
        local inst = trade["item" .. x];
        if (inst.valid) then
            item_data[x] = inst
        end
    end

    local required_data = {}
    for i = 1, 4 do
        local key = "item" .. i;
        local item_id = trade_check[key]
        if item_id ~= nil and item_id ~= 0 then
            if required_data[item_id] ~= nil then
                required_data[item_id] = required_data[item_id] + 1
            else
                required_data[item_id] = 1
            end
        end
    end

    local currencies = { "platinum", "gold", "silver", "copper" }
    for _, currency in ipairs(currencies) do
        if trade_check[currency] ~= nil and trade_check[currency] ~= 0 then
            required_data[currency] = trade_check[currency]
        end
    end
    for _, currency in ipairs(currencies) do
        if trade[currency] ~= nil and trade[currency] ~= 0 then
            handin_data[currency] = trade[currency]
        end
    end

    if (trade.self) then
        return trade.self:CheckHandin(trade.other, handin_data, required_data, item_data);
    else
        return false
    end
end

function items.return_items(npc, client, trade, text)
    npc:ReturnHandinItems(client);
end

return items
`
	os.MkdirAll("lua_modules", 0755)
	os.WriteFile("lua_modules/items.lua", []byte(realItemsLua), 0644)
}
