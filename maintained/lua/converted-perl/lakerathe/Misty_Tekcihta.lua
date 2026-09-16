-- Source: lakerathe/Misty_Tekcihta.pl
-- Bard Epic 1.0: Misty Tekcihta finishes the torch relay.
-- Converted from ProjectEQ Perl quest script.
-- items: 20534, 20379

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("smiles and taps her foot.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20534}) then
		e.self:Emote("hands you a small ring.")
		e.other:SummonItem(20379) -- Proof of Speed
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
