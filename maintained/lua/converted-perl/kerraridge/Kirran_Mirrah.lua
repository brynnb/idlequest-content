-- Converted from ProjectEQ Perl quest script.
-- Source: kerraridge/Kirran_Mirrah.pl
-- items: 9968, 9967

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 9968}) then
		e.self:Say("Ahhhhhhhh! I can't believe that you ---- ahhhhhhhh! Die you, you, you evil evil heretic!")
		eq.attack(e.other:GetName())
		e.other:SummonItem(9967)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
