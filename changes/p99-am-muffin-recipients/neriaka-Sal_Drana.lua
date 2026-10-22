-- Converted from ProjectEQ Perl quest script.
-- Source: neriaka/Sal_Drana.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Greetings. I am pleased to report that I am fully stocked. Please have a look at the goods I have for sale.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	-- P99 documented final crate hand-in; removed starter dialogue stays absent.
	if item_lib.check_turn_in(e.trade, {item1 = 1839}) then
		e.self:Say("Very good work. I can see you are a talented baker and these muffins look suitable. You do Neriak a great service. Here is your payment. I look forward to conducting future business with you.")
		e.other:GiveCash(0, 0, 7, 0)
		e.other:Faction(236, 2, 0)
		e.other:Faction(334, 1, 0)
		e.other:Faction(370, 1, 0)
		-- Explicit partial restoration: raw XP remains unverified and omitted.
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
