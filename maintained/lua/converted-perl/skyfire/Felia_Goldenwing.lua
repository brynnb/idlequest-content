-- Source: skyfire/Felia_Goldenwing.pl
-- Enchanter Epic 1.0: Felia Goldenwing Enchanted Sapphire.
-- Converted from ProjectEQ Perl quest script.
-- items: 10632, 10619

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10632}) then
		e.other:SummonItem(10619) -- Enchanted Sapphire
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
