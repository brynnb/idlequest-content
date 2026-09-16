-- Converted from ProjectEQ Perl quest script.
-- Source: oggok/Horgus.pl
-- P99: https://wiki.project1999.com/Lizard_Tails
-- items: 13354, 2137, 2140, 2142, 2144, 2146, 2147, 2148

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("What!!? You [Craknek] or you [pest]?")
	elseif e.message:findi("craknek") then
		e.self:Say("Good. Me not bash you. You help Horgus and Crakneks. Go smash lizards. Bring four tails. Greenbloods think they get all lizard tails. We take first. Taste good. You bring four tails. Me give you tings. Me gives armur. Now go!!")
	elseif e.message:findi("pest") then
		e.self:Say("Bah!! You go join Greenbloods. You weak.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13354, item2 = 13354, item3 = 13354, item4 = 13354}) then
		e.self:Say("Mmmhmm!! Me favorites!! You do gud, here, take dis armur.")
		e.other:SummonItem(eq.ChooseRandom(2137, 2140, 2142, 2144, 2146, 2147, 2148))
		e.other:Faction(228, 10, 0)
		e.other:Faction(232, 10, 0)
		e.other:Faction(261, -10, 0)
		e.other:AddEXP(500)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
