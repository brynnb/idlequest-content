-- Source: oggok/Brokk_Boxtripper.pl
-- Enchanter Epic 1.0: Brokk Boxtripper snow blossoms chain.
-- Converted from ProjectEQ Perl quest script.
-- items: 10629, 10630

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10629}) then
		e.self:Say("Brokk sorry. Go give her these perty flowers.")
		e.other:SummonItem(10630) -- Gift to Bozlum
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
