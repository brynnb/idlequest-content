-- Converted from ProjectEQ Perl quest script.
-- Source: oggok/Uglan.pl
-- items: 16547

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 16547}) then
		e.self:Say("Ay, I be needin ya to intercept an Orc Runner carryin a sealed letter. Get da letter and give it ta Lork.")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
