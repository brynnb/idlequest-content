-- Converted from ProjectEQ Perl quest script.
-- Source: commons/Timtok_Tonsmith.pl
-- items: 4178, 4186, 4176, 4184, 4173, 4181, 4180, 4188

local function resize_reward(e)
	e.self:Say("Here is your armor. I hope it fits better now.")
	e.other:Faction(229, 10, 0)
	e.other:Faction(281, 10, 0)
	e.other:Faction(291, 10, 0)
	e.other:Faction(5015, 10, 0)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail! I am Timtok Tonsmith. My brother Ranvigoz and I are some of the finest smiths this side of Kaladim. If you are interested we will happily [resize] your [Crafted Armor] down to a more manageable size.")
	elseif e.message:findi("resize") then
		e.self:Say("I will resize Crafted Gauntlets, a Vambrace, a Helm or Boots. My brother will resize Crafted Bracers, Greaves, a Pauldrun or a Breastplate. Just give me the armor and I will resize it for you.")
	elseif e.message:findi("crafted armor") then
		e.self:Say("Crafted Armor is made by the Meadowgreen smiths. They can be found in the southern part of the Karanas.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 4178}) then
		e.other:SummonItem(4186)
		resize_reward(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 4176}) then
		e.other:SummonItem(4184)
		resize_reward(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 4173}) then
		e.other:SummonItem(4181)
		resize_reward(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 4180}) then
		e.other:SummonItem(4188)
		resize_reward(e)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
