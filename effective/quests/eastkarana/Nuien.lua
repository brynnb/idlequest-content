-- Source: eastkarana/Nuien.pl
-- Ranger Epic 1.0: Nuien passes the Frayed Braided Grass Amulet to Teloa.
-- Converted from ProjectEQ Perl quest script.
-- items: 20451

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20451}) then
		e.self:Say("So be it. Do as you have done before and find the next. Teloa is the last.")
		e.other:SummonItem(20451) -- Frayed Braided Grass Amulet
		eq.spawn2(15170, 0, 0, -2854, -3840, 126.5, 123.6)
		eq.signal(15044, 15167)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_signal(e)
	if e.signal == 99 then
		e.self:Emote("growls as his power seeps into the earth.")
	else
		e.self:MoveTo(-1590, -3671, -18)
	end
end
