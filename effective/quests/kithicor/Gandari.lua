-- Converted from ProjectEQ Perl quest script.
-- Source: kithicor/Gandari.pl
-- items: 10569, 10546, 10033, 3189, 10566, 10570, 10034, 3181, 10548, 10568, 10032, 3188, 10571, 10567, 10035, 3184

local function ivy_reward(e, item_id)
	e.other:SummonItem(item_id)
	e.other:Ding()
	e.self:Say("Well done. May Karana bless your soul.")
	e.other:Faction(269, 30, 0)
	e.other:Faction(302, 30, 0)
	e.other:Faction(272, 30, 0)
	e.other:Faction(324, -60, 0)
	e.other:AddEXP(10000)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Most call me Gandari the Terse.  You here for [ivy armor]?")
	elseif e.message:findi("ivy armor") then
		e.self:Say("I reward brave rangers with ivy etched armor - [Helm]s. [Tunic]s. [Sleeves] and [Bracers]. [Interested]?")
	elseif e.message:findi("bracers") then
		e.self:Say("I do not haggle, I do not bargain. The Bottom of the Rune of Ivy from the plains of Everfrost, a Watery Ring from the Cauldron of Tears and a Fire Emerald to warm my heart. Bring these to me and you shall earn your reward.")
	elseif e.message:findi("helm") then
		e.self:Say("I do not haggle, I do not bargain. The Top of the Rune of Ivy from the Castle Mistmoore, a Cyclops Charm from Tarskuk and a Sapphire of Sky Blue. Bring these to me and you shall earn your reward.")
	elseif e.message:findi("sleeve") then
		e.self:Say("I do not haggle, I do not bargain. A Heart of Fire from the Caverns of Solusek, the Left side of the Rune of Ivy from the Griffon Grimfeather and two Star Rubies of sparkling hue. Bring these to me and you shall earn your reward.")
	elseif e.message:findi("tunic") then
		e.self:Say("I do not haggle, I do not bargain. The Skull of Meldrath, the Right side of the Rune of Ivy from the Thistle Brownie and two Rubies of Fiery Red. Bring these to me and you shall earn your reward.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10569, item2 = 10546, item3 = 10033}) then
		ivy_reward(e, 3189)
	elseif item_lib.check_turn_in(e.trade, {item1 = 10566, item2 = 10570, item3 = 10034}) then
		ivy_reward(e, 3181)
	elseif item_lib.check_turn_in(e.trade, {item1 = 10548, item2 = 10568, item3 = 10032, item4 = 10032}) then
		ivy_reward(e, 3188)
	elseif item_lib.check_turn_in(e.trade, {item1 = 10571, item2 = 10567, item3 = 10035, item4 = 10035}) then
		ivy_reward(e, 3184)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
