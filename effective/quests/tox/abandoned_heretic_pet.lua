-- Converted from ProjectEQ Perl quest script.
-- Source: toxxulia/abandoned_heretic_pet.pl
-- items: 13894, 10011, 10015, 10016, 10018, 10020, 10022, 10023, 10029

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13894}) then
		e.self:Say("Good work, you should be running this operation instead of that Talrigar fellow. Have a small reward. A little bit of the gems I found while tunneling through this rock.")
		e.other:AddEXP(100)
		e.other:SummonItem(eq.ChooseRandom(10011, 10015, 10016, 10018, 10020, 10022, 10023, 10029))
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
