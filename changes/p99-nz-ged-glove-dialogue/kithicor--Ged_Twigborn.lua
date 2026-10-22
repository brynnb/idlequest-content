-- Converted from ProjectEQ Perl quest script.
-- Source: kithicor/Ged_Twigborn.pl
-- P99 audit: Ratskin Gloves Quest
-- items: 13766, 2315, 13752, 2314, 13054, 2312, 13755, 2313

local function reward_gloves(e, item_id)
	e.other:SummonItem(item_id)
	e.other:Faction(269, 5, 0) -- Kithicor Residents
	e.other:Faction(302, 5, 0) -- Protectors of Pine
	e.other:Faction(272, 5, 0) -- Jaggedpine Treefolk
	e.other:Faction(324, -5, 0) -- Unkempt Druids
	e.other:AddEXP(100)
	e.other:Ding()
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello Traveler.  Don't mind me, I'm just working on some [clothes]")
	elseif e.message:findi("clothes") or e.message:findi("garments") then
		e.self:Say("Well, more like [gloves] actually, they are my specialty.")
	elseif e.message:findi("bear") then
		e.self:Say("If you would like gloves from bear skin I require a bear hide and 25 gold pieces.")
	elseif e.message:findi("rat") then
		e.self:Say("I will need 6 gold, and a giant rat pelt.")
	elseif e.message:findi("wolf") then
		e.self:Say("I will require 13 gold pieces and a wolf pelt.")
	elseif e.message:findi("gloves") then
		e.self:Say("Aye, gloves.  I would be happy to make you a pair if you can bring me a lion skin and 96 gold pieces.  I also make them from [bear] skin, [wolf] skin, or [rat] skin.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13766, gold = 96}) then
		reward_gloves(e, 2315)
	elseif item_lib.check_turn_in(e.trade, {item1 = 13752, gold = 25}) then
		reward_gloves(e, 2314)
	elseif item_lib.check_turn_in(e.trade, {item1 = 13054, gold = 6}) then
		e.self:Say("Ahh yes, these will do quite nicely. Here are your ratskin gloves.")
		reward_gloves(e, 2312)
	elseif item_lib.check_turn_in(e.trade, {item1 = 13755, gold = 13}) then
		reward_gloves(e, 2313)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
