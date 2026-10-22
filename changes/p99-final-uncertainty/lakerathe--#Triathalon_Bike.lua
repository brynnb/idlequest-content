-- enabled: false
-- P99 excludes this exact later or custom-event quest chain; full callbacks retained.
-- Evidence: changes/p99-final-uncertainty/review.json
-- Converted from ProjectEQ Perl quest script.
-- Source: lakerathe/#Triathalon_Bike.pl
-- items: 16889, 21800

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello, " .. e.other:GetName() .. "! If you visited with my friend on the island you should have something to give me.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 16889}) then
		e.self:Say("Excellent, congratulations  on completing the swim.  Here is something that will help you cross South Karana.  Don't forget to give this to my friend on the bridge before crossing into North Karana.")
		e.other:SummonItem(21800)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
