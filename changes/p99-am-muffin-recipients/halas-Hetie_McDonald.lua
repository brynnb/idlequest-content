function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Welcome back, " .. e.other:GetName() .. ". Why don't you purchase a few things before you head out into the tundra again?");
	end
end

-------------------------------------------------------------------------------------------------
-- Converted to .lua using MATLAB converter written by Stryd and manual edits by Speedz
-- Find/replace data for .pl --> .lua conversions provided by Speedz, Stryd, Sorvani and Robregen
-------------------------------------------------------------------------------------------------

function event_trade(e)
	local item_lib = require("items")
	-- P99 documented final crate hand-in; removed starter dialogue stays absent.
	if item_lib.check_turn_in(e.trade, {item1 = 1839}) then
		e.self:Say("Oh, yes, this is exactly what I needed. These muffins look very fresh too, good work! Here is your payment, as promised. It was a pleasure doing business with you.")
		e.other:GiveCash(0, 0, 7, 0)
		e.other:Faction(328, 2, 0)
		e.other:Faction(320, 1, 0)
		e.other:Faction(327, 1, 0)
		-- Explicit partial restoration: raw XP remains unverified and omitted.
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
