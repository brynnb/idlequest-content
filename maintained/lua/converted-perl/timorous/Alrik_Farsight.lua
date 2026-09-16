-- Source: timorous/Alrik_Farsight.pl
-- Ranger Epic 1.0: Alrik Farsight gives Ancient Pattern.
-- Converted from ProjectEQ Perl quest script.
-- items: 20457, 20474, 18960

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Ah. Hello there, adventurer. Come to search for ancient artifacts with Fizzlebik and myself?")
	elseif e.message:findi("ancient bowl") then
		e.self:Say("If you helped me out on a chore I have, I'd be happy to give it to you.")
	elseif e.message:findi("take the artifact") then
		e.self:Say("Hah! Okay, then. Here take this to Farios Elianos in Felwithe.")
		e.other:SummonItem(20457) -- Crushed Pot
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20474}) then
		e.self:Emote("grins happily.")
		e.other:SummonItem(18960) -- Ancient Pattern
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
