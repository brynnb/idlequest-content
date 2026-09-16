-- Converted from ProjectEQ Perl quest script.
-- Source: karnor/a_human_skeleton.pl
-- items: 12964, 12967

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Save my.. Soul.. Find.. Wizard.. Desp..")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12964}) then
		e.other:SummonItem(12967) -- Bottle of swirling smoke
		eq.depop_with_timer()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

