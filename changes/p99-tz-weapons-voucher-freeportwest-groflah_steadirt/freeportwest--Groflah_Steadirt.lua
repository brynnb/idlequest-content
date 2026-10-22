-- Source: freeportwest/Groflah_Steadirt.lua
-- P99 audit: Weapons Delivery
-- items: 18820, 18818, 13919, 5418

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Greetings, adventurer! Certainly a person who looks as hardened as yourself deserves a fine blade to match your prowess. Here at Groflah's Forge, we supply you with only the finest quality weapons.")
	elseif(e.message:findi("ariska zimel")) then
		e.self:Say("Zimel!! I do not know who you mean. Now go away. I am very busy. I will not talk here!!")
	end
end

function event_trade(e)
	local item_lib = require("items")

	if item_lib.check_turn_in(e.trade, {item1 = 18820}) then
		e.self:Say("I am afraid I have some bad news, Steel Warrior. I had one of my workers take the raw blades out to be engraved by the Rivervale craftsmen. On his return, he was killed by the orcs in the Commonlands. The orcs now have the blades in their possession. I believe they have a camp nearby in the Commonlands. You may still be able to find all four blades within their camp and return them to Larn Brugal. Good luck.")
		e.other:AddEXP(100)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 13919}) then
		e.self:Say("I heard you were on your way back. Here, then. Let us sharpen that blade for you. There you are. That should be much better in a fray now.")
		e.other:SummonItem(5418) -- Groflah's Stoutbite
		e.other:Faction(229, 10, 0) -- Coalition of Tradefolk
		e.other:Faction(281, 10, 0) -- Knights of Truth
		e.other:Faction(291, 10, 0) -- Merchants of Qeynos
		e.other:Faction(336, 10, 0) -- Coalition of Tradefolk Underground
		e.other:AddEXP(500)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 18818}) then
		e.self:Say("Where did you find this? This was the main price list of Zimel's Blades, but it should be all burnt up. I was at Zimel's right after the fire and I did not see it hanging where it should have been. The entire inside was gutted and . . . wait . . . the sequence of the dots!! Hmmm. I cannot talk with you here. Meet me at the Seafarer's by the docks at night. Give me the note when next we meet.")
		e.other:SummonItem(18818) -- Tattered Flier
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
