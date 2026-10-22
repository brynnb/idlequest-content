function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Hello there " .. e.other:GetName() .. "! You'll be happy to see that I am fully stocked with all my usual goods. Have a look around!");
	end
end

-- END of FILE Zone:erudnext  ID:98057 -- Beth_Breadmaker 


function event_trade(e)
	local item_lib = require("items")
	-- P99 documented final crate hand-in; removed starter dialogue stays absent.
	if item_lib.check_turn_in(e.trade, {item1 = 1839}) then
		e.self:Say("Ah yes! This is exactly what I am looking for, dear. Let me put these on the shelf right away. Here is some coin for your trouble. Perhaps we can do business again sometime.")
		e.other:GiveCash(0, 0, 0, 1)
		e.other:Faction(289, 2, 0)
		e.other:Faction(266, 1, 0)
		e.other:Faction(267, 1, 0)
		-- Explicit partial restoration: raw XP remains unverified and omitted.
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
