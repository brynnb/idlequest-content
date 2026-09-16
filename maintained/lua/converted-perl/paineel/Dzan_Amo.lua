-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Dzan_Amo.pl
-- items: 13069, 13250, 15014, 15201, 15203, 15205, 15207, 15208, 15209, 15210

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome to the Tabernacle of Terror. Perhaps you can control your fear long enough to be of [service] to us.")
	elseif e.message:findi("service") then
		e.self:Say("I need some things fetched from the creatures just outside our city for some ritual experimentation. Bring me two tufts of bat fur and two fire beetle legs and I will school you in the ways of terror.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13069, item2 = 13069, item3 = 13250, item4 = 13250}) then
		e.self:Say("Very good young one. Here is something to assist in your studies of the principles of terror.")
		e.other:SummonItem(eq.ChooseRandom(15203, 15207, 15201, 15208, 15209, 15014, 15205, 15210))
		e.other:Faction(265, 5, 0)
		e.other:Faction(242, -5, 0)
		e.other:Faction(254, -5, 0)
		e.other:Faction(231, -5, 0)
		e.other:Faction(233, -5, 0)
		e.other:AddEXP(1000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
