-- Converted from ProjectEQ Perl quest script.
-- Source: gfaydark/Mazziana_Ridgerunner.pl
-- items: 13791

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello, " .. e.other:GetName() .. ".")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13791, item2 = 13791, item3 = 13791, item4 = 13791}) or
		item_lib.check_turn_in(e.trade, {item1 = 13791, item2 = 13791, item3 = 13791}) or
		item_lib.check_turn_in(e.trade, {item1 = 13791, item2 = 13791}) or
		item_lib.check_turn_in(e.trade, {item1 = 13791}) then
		e.self:Say("Ah, yes. Good work, thank you.")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
