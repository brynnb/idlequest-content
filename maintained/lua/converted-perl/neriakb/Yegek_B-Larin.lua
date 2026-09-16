-- Converted from ProjectEQ Perl quest script.
-- Source: neriakb/Yegek_B-Larin.pl
-- P99 audit: Yegek's Test, Part 1; Yegek's Test, Part 2
-- name: Yegek_B-Larin
-- items: 17942, 13887, 5001, 13888, 10715, 13005, 13002

local function yegek_faction(e, amount)
	e.other:Faction(270, amount, 0) -- Indigo Brotherhood
	e.other:Faction(326, -math.max(1, math.floor(amount / 10)), 0) -- Emerald Warriors
	e.other:Faction(311, -math.max(1, math.floor(amount / 10)), 0) -- Steel Warriors
end

function event_say(e)
	local fac = e.other:GetFaction(e.self)

	if e.message:findi("hail") then
		e.self:Say("Welcome. A brother of the Indigo you must be. Why else would anyone dare to roam the corridors of the Cauldron of Hate? You were most likely sent to speak with Yegek. If so, speak up and tell Yegek who [sent] you.")
	elseif e.message:findi("seloxia punox sent me") or e.message:findi("seloxia sent me") then
		if fac <= 4 then
			e.self:Say("Good. Let us begin your training. Take this and fill it with three fire beetle eye and three bone chips found on the creatures that infest Nektulos Forest. Combine the items in the bag, and give it to me. Hold onto the basic short sword you first received from Seloxia for you will need this for the next part of your training.")
			e.other:SummonItem(17942) -- Empty Bag, Bag for Beetle Eyes and Bones
		else
			e.self:Say("You have not yet earned the trust of the Indigo Brotherhood. Return when your reputation is worthy.")
		end
	elseif e.message:findi("second test") then
		if fac <= 4 then
			e.self:Say("You think you are ready for the final test? To prove you worth, you will fight a cowardly Teir'Dal in hand to hand combat. You must first relinquish your basic short sword to me in order for us to begin the duel. I hope you have been honing your skills in battle, you'll need it! Once you are ready, hand me the blade and we'll begin!")
		else
			e.self:Say("You have not yet earned the trust of the Indigo Brotherhood. Return when your reputation is worthy.")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	local fac = e.other:GetFaction(e.self)

	if fac <= 4 and item_lib.check_turn_in(e.trade, { item1 = 13887 }) then -- Bag of Eyes n Bones
		e.self:Say("Excellent, you have passed the first test. Take this as a small reward for your fortitude. Do you feel you are ready for the [second test]?")
		yegek_faction(e, 5)
		e.other:SummonItem(eq.ChooseRandom(13005, 13002)) -- Iron Ration or Torch
		e.other:GiveCash(0, 4, 0, 0)
		e.other:AddEXP(150)
		e.other:Ding()
	elseif fac <= 4 and item_lib.check_turn_in(e.trade, { item1 = 5001 }) then -- starting Short Sword
		e.self:Say("Good. The blade is gone. Now show me whether you are predator or prey.")
		eq.spawn2(41098, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()) -- TeirDal_coward
	elseif fac <= 4 and item_lib.check_turn_in(e.trade, { item1 = 13888 }) then -- Teir`Dal Head, Dark Elf Head - Coward
		e.self:Say("Hah!! Well done, very entertaining duel! Here... you have earned the right to wear this blade. Let anyone whose eyes fall on it to shudder in fear of the Indigo Brotherhood!!")
		yegek_faction(e, 10)
		e.other:SummonItem(10715) -- Sullied Two Handed Sword
		e.other:AddEXP(300)
		e.other:Ding()
	end

	item_lib.return_items(e.self, e.other, e.trade)
end
