-- Source: gfaydark/Regren.pl
-- items: 18782, 13533, 13073, 13782, 13253, 13069, 5014, 6015, 5019, 6011, 5021, 7010, 7009, 5025, 6013, 5043, 5046, 5044, 6032, 6030, 6033, 7023, 5047, 7022, 7024, 5071, 5070

local function emerald_warriors_amiable_or_better(e)
	return e.other:GetFaction(e.self) <= 4
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome, " .. e.other:GetName() .. "!  Show the Emerald Warriors your mettle and bring me a ruined wolf pelt, some bat fur, some bone chips, and a spiderling eye from the depths of Greater Faydark. If you succeed, my admiration and a reward will be yours. To battle!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18782}) then
		e.self:Say("Welcome to the Emerald Warriors. Hmmm, you have a lot of training to do, so lets get started right away. Here's our guild tunic. Represent us well, young " .. e.other:GetName() .. ".")
		e.other:SummonItem(13533)
		e.other:AddEXP(100)
		e.other:Faction(326, 100, 0)
		e.other:Faction(270, -15, 0)
		e.other:Faction(325, 10, 0)
		e.other:Faction(276, 10, 0)
		e.other:Ding()
	elseif emerald_warriors_amiable_or_better(e) and item_lib.check_turn_in(e.trade, {item1 = 13073, item2 = 13782, item3 = 13253, item4 = 13069}) then
		e.self:Say("Fine work! You are on your way to becoming an adequate combatant.")
		e.other:SummonItem(eq.ChooseRandom(5014, 6015, 5019, 6011, 5021, 7010, 7009, 5025, 6013, 5043, 5046, 5044, 6032, 6030, 6033, 7023, 5047, 7022, 7024, 5071, 5070))
		e.other:Faction(326, 10, 0)
		e.other:Faction(270, -10, 0)
		e.other:Faction(276, 10, 0)
		e.other:Faction(325, 10, 0)
		e.other:AddEXP(500)
		e.other:GiveCash(2, 2, 0, 0)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
