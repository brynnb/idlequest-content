-- Converted from ProjectEQ Perl quest script.
-- Source: firiona/Drake_Mountainstorm.pl
-- items: 10033, 10013

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10033}) then
		e.self:Emote("examines the fire emerald, reaches into his pouch and hands you another. 'There you go, it doesn't look special but it is. If you don't believe me I'll take another look at it. Just remember this special fire emerald only has one purpose!'")
		e.other:SummonItem(10013)
	else
		e.self:Say("I have no need for this, " .. e.other:GetName() .. ".")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
