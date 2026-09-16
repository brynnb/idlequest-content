-- Converted from ProjectEQ Perl quest script.
-- Source: trakanon/a_human_skeleton.pl
-- items: 12962, 12965

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Save my.. Soul.. Find.. Wizard.. Desp..")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12962}) then
		e.other:SummonItem(12965)
		eq.depop()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
