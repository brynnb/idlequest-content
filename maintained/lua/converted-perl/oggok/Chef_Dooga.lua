-- Converted from ProjectEQ Perl quest script.
-- Source: oggok/Chef_Dooga.pl
-- P99: https://wiki.project1999.com/Feeding_Dooga
-- items: 13384, 13364, 13365, 13452, 12217

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome you. You look all skin 'n bones. Eat you must do. Chef Dooga can fix up goodies for you. Try [HEHE meat].")
	elseif e.message:findi("hehe meat") then
		e.self:Say("It is a secret ground meat made with high elf, human, and Erudite Flesh. Mmmm. It good stuff. Dooga make it and [the Gobbler] make it. If you find any of those meats in the swamps bring to me and I pay you.")
	elseif e.message:findi("gobbler") then
		e.self:Say("You no hear of the Gobbler!! Him great butcher. Have all kinds of meat. Him am low on froglok legs. Dooga supply him. Dooga need someone to [deliver froglok legs].")
	elseif e.message:findi("froglok legs") then
		e.self:Say("You think so!! That be good thing. Make the Gobbler happy. Maybe he give you something good. Maybe not. You take this. Deliver meat.")
		e.other:SummonItem(13384)
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13364}) then
		e.self:Say("MmmmMmm. Human make good meat pies. Here. A little coins for you.")
		e.other:Ding()
		e.other:AddEXP(1000)
		e.other:Faction(228, 10, 0)
		e.other:Faction(232, 10, 0)
		e.other:Faction(261, 10, 0)
		e.other:Faction(337, 10, 0)
		e.other:Faction(274, -15, 0)
		e.other:GiveCash(eq.ChooseRandom(5, 6, 7, 8, 9), 0, 0, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 13365}) then
		e.self:Say("High elf! Now that is a good meat. Goes good with Ogre Swill.")
		e.other:Ding()
		e.other:AddEXP(1000)
		e.other:Faction(228, 10, 0)
		e.other:Faction(232, 10, 0)
		e.other:Faction(261, 10, 0)
		e.other:Faction(337, 10, 0)
		e.other:Faction(274, -15, 0)
		e.other:GiveCash(0, 5, 0, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 13452, item2 = 13452, item3 = 13452, gold = 10}) then
		e.self:Say("You gud baker!! Here take dis, it got sum stains, but still gud.")
		e.other:SummonItem(12217)
		e.other:Ding()
		e.other:AddEXP(1000)
		e.other:Faction(228, 10, 0)
		e.other:Faction(232, 10, 0)
		e.other:Faction(261, 10, 0)
		e.other:Faction(337, 10, 0)
		e.other:Faction(274, -15, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
