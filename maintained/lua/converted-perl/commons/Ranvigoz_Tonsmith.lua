-- Converted from ProjectEQ Perl quest script.
-- Source: commons/Ranvigoz_Tonsmith.pl
-- items: 4177, 4185, 4179, 4187, 4175, 4183, 4174, 4182

local function resize_reward(e)
	e.self:Say("Here is your armor. I hope it fits better now.")
	e.other:Faction(229, 10, 0)
	e.other:Faction(281, 10, 0)
	e.other:Faction(291, 10, 0)
	e.other:Faction(5015, 10, 0)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail! I am Ranvigoz Tonsmith. My brother Timtok and I are some of the finest smiths this side of Kaladim. If you are interested we will happily [resize] your [Crafted Armor] down to a more manageable size.")
	elseif e.message:findi("resize") then
		e.self:Say("I will resize Crafted Bracers, Greaves, a Pauldron or a Breastplate. My brother will resize Crafted Gauntlets, a Vambrace, a Helm or Boots. Just give me the armor and I will resize it for you.")
	elseif e.message:findi("crafted armor") then
		e.self:Say("Crafted Armor is made by the Meadowgreen smiths. They can be found in the southern part of the Karanas.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 4177}) then
		e.other:SummonItem(4185)
		resize_reward(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 4179}) then
		e.other:SummonItem(4187)
		resize_reward(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 4175}) then
		e.other:SummonItem(4183)
		resize_reward(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 4174}) then
		e.other:SummonItem(4182)
		resize_reward(e)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
