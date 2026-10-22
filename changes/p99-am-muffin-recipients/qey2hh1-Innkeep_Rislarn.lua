function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say(string.format("Welcome to my shop %s. You'll be happy to hear that I'm fully stocked. It's nice that things are back to normal now that the plague is over.",e.other:GetName()));
	end
end

-- END of FILE Zone:qey2hh1  ID:2742 -- Innkeep_Rislarn
function event_trade(e)
	local item_lib = require("items")
	-- P99 documented final crate hand-in; removed starter dialogue stays absent.
	if item_lib.check_turn_in(e.trade, {item1 = 1839}) then
		e.self:Say("Ah, praise Karana! These muffins look good enough to eat, har har har! Here is your payment and you have my deepest gratitude. We have to stick together in these times of turmoil you know.")
		e.other:GiveCash(0, 0, 8, 0)
		e.other:Faction(291, 2, 0)
		e.other:Faction(223, -1, 0)
		e.other:Faction(219, 1, 0)
		e.other:Faction(229, 1, 0)
		e.other:Faction(262, 1, 0)
		-- Explicit partial restoration: raw XP remains unverified and omitted.
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
