-- Converted from ProjectEQ Perl quest script.
-- Source: soltemple/Syllina.pl
-- items: 1355, 3318, 3317

local function temple_faction(e)
	e.other:Faction(415, 15, 0)
	e.other:Faction(416, -15, 0)
	e.other:AddEXP(1000)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello, I am Syllina, follower of Solusek Ro and keeper of the [Shadow Lore].")
	elseif e.message:findi("shadow lore") then
		e.self:Say("I hold the secrets to the Shadow Lore so highly prized by Necromancers. If you are interested, I can tell you about [ShadowBound Boots], [ShadowBound Gloves], the [Robe of Enshroudment] or the secrets to the making of [Shadow Silk].")
	elseif e.message:findi("shadowbound boots") then
		e.self:Say("ShadowBound Boots are boots woven from purest shadow. If you are interested, I will weave you a pair - but I will need [boot components].")
	elseif e.message:findi("boot components") then
		e.self:Say("I will need the following items to make you a pair of ShadowBound Boots: Shadow Silk, The Scepter of Sorrow from Castle Mistmoore, an Eye of Shadow from our mortal enemies the Shadowed Men and a Skeletal toe from a Rathe Giant Skeleton.")
	elseif e.message:findi("shadowbound gloves") then
		e.self:Say("ShadowBound Gloves are gloves woven from the purest shadow. If you are interested, I will weave you a pair - but I will need [glove components].")
	elseif e.message:findi("glove components") then
		e.self:Say("I will need the following items to make you a pair of ShadowBound Gloves: Inky Shadow Silk, The Scepter of Tears from the circle-stair-waterfall of Guk, a Hand of Shadow from our mortal enemies the Shadowed Men and a Skeletal finger from a Rathe Giant Skeleton.")
	elseif e.message:findi("robe of enshroudment") then
		e.self:Say("The Robe of Enshroudment is a robe woven from the purest of shadow. If you are interested, I will weave you a robe - but I will need the following [robe components].")
	elseif e.message:findi("robe components") then
		e.self:Say("I will need the following items to make you a Robe of Enshroudment: Large Shadow Silk, A Werebat Wing from the Estate of Unrest, A Mask of Shadow from our mortal enemies the Shadowed Men and a Globe of Shadow from a Nokta Shaman in Guk.")
	elseif e.message:findi("shadow silk") then
		e.self:Say("If you are interested, I will tell you the secrets of making Shadow Silk for a mere 50 pieces of gold.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {gold = 50}) then
		e.self:Say("You will need to give the following components to a tailor: a Shadow Wolf Pelt, a Silk Swatch and a Scroll of Gather Shadows. Have the tailor weave them together and she will make you Shadow Silk. To make large shadow silk add an extra shadow wolf pelt. To make inky shadow silk, add an extra scroll.")
		e.other:Faction(415, 1, 0)
		e.other:Faction(416, -1, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 16484, item2 = 13239, item3 = 2309, item4 = 10535}) then
		e.self:Say("Well done, " .. e.other:GetName() .. "! Here is your robe, as promised.")
		e.other:SummonItem(1355)
		temple_faction(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 14363, item2 = 13234, item3 = 10534, item4 = 16485}) then
		e.self:Say("Well done, " .. e.other:GetName() .. "! Here are your gloves, as promised.")
		e.other:SummonItem(3318)
		temple_faction(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 14364, item2 = 13180, item3 = 10533, item4 = 16483}) then
		e.self:Say("Well done, " .. e.other:GetName() .. "! Here are your boots, as promised.")
		e.other:SummonItem(3317)
		temple_faction(e)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
