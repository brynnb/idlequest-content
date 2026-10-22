function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Huh? Oh hi " .. e.other:GetName() .. ". Youse want to buy sumthin?");
	end
end

-- END of FILE Zone:feerrott  ID:47144 -- Innkeep_Gub
function event_trade(e)
	local item_lib = require("items")
	-- P99 documented final crate hand-in; removed starter dialogue stays absent.
	if item_lib.check_turn_in(e.trade, {item1 = 1839}) then
		e.self:Say("MMmmm... Deez look like gud muffins. Here's sum money. Tanks. Now meez all stocked again.")
		e.other:GiveCash(0, 0, 8, 0)
		e.other:Faction(338, 2, 0)
		e.other:Faction(228, 1, 0)
		e.other:Faction(337, 1, 0)
		-- Explicit partial restoration: raw XP remains unverified and omitted.
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
