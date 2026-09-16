-- Source: soltemple/Solomen.pl
-- Wizard Epic 1.0: Solomen note starter and final Staff of the Four hand-in.
-- Converted from ProjectEQ Perl quest script.
-- items: 18088, 14340, 14341

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Ah, I see you have found my study. This is where I study and scribe the history of magic in Norrath.")
	elseif e.message:findi("history") then
		e.self:Say("I have worked to chronicle everything from the beginnings of magic to what we consider the modern day of magic.")
	elseif e.message:findi("wizards") then
		e.self:Say("I have here an envelope that I need delivered to one Camin. You can find him near the wizard tower in the city of Erudin. Do you agree to undertake my task?")
	elseif e.message:findi("agree") then
		e.self:Say("Here you are, then. Good luck on your journey.")
		e.other:SummonItem(18088) -- Note to Camin
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 14340}) then
		e.self:Say("You actually did it! Here, take this staff and know that you have made Solusek Ro and all the wizards of the world proud this day.")
		e.other:SummonItem(14341) -- Staff of the Four
		e.other:Faction(404, -100) -- Truespirit
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
