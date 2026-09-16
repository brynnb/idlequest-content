-- Converted from ProjectEQ Perl quest script.
-- Source: kerraridge/Errrak_Thickshank.pl
-- items: 7005, 13737, 13762, 10139

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("What?  What do you want. furless?  My tseq. Graalf. lies sick and you waste time with talk when you [cannot help].")
	elseif e.message:findi("help") then
		e.self:Say("The shamans. they have said I need [talismans] to ward the sickness from Graalf.")
	elseif e.message:findi("talisman") then
		e.self:Say("Errr?  You wish to help?  We will see.  I need a tiger's skin. from a tigerrr not of ourrr village. for its brave spirit. an aviaks charm. and a giant snake fang for the poison that can be made into an antidote.  If you truly intend to help. then good speed and hurry!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 7005, item2 = 13737, item3 = 13762}) then
		e.self:Say("I cannot believe. Thank you. Please, take this talisman. I bought from wandering shaman but it no help Graalf, maybe it help you. Now please go, Errrak must see if this help Graalf.")
		e.other:SummonItem(10139)
		e.other:Faction(382, 10, 0) -- Kerra Isle
		e.other:AddEXP(1000)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
