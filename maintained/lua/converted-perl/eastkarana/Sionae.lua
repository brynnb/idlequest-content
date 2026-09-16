-- Source: eastkarana/Sionae.pl
-- Ranger Epic 1.0: Sionae passes the Braided Grass Amulet to Nuien.
-- Converted from ProjectEQ Perl quest script.
-- items: 20450, 20451

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20450}) then
		e.self:Say("I see that the time has come. Take the amulet and give it to the third of our kin, Nuien.")
		e.other:SummonItem(20451) -- Frayed Braided Grass Amulet
		eq.spawn2(15167, 0, 0, 300, -3657, 3, 366)
		eq.signal(15044, 15178)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_signal(e)
	if e.signal == 99 then
		e.self:Emote("shivers as her power flows into the air above the gathering.")
	else
		-- Persist the same actor at the gathering; no replacement spawn needed.
		e.self:MoveTo(-1584, -3669, -18)
	end
end
