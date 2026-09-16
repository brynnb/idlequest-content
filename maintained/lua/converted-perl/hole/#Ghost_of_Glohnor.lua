-- Source: hole/#Ghost_of_Glohnor.pl
-- Shadow Knight Epic 1.0: Ghost of Glohnor spawns Mummy of Glohnor.
-- Converted from ProjectEQ Perl quest script.
-- items: 14377

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 14377}) then
		eq.spawn2(39165, 0, 0, 464.4, 819, -678, 250) -- Mummy_of_Glohnor
		e.other:Faction(404, 7)
		eq.depop_with_timer()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
