-- Source: eastkarana/Teloa.pl
-- Ranger Epic 1.0: Teloa starts the corruptor encounter.
-- Converted from ProjectEQ Perl quest script.
-- items: 20451

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20451}) then
		e.self:Emote("begins walking toward the gathering spot. 'Follow, friend.'")
		eq.signal(15044, 1)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_signal(e)
	if e.signal == 99 then
		e.self:Emote("breathes slowly as tendrils of power emanate from her body and race along the ground.")
	else
		e.self:MoveTo(-1597, -3670, -18)
	end
end
