-- Source: overthere/Impaler_Tzilug.pl
-- Enchanter Epic 1.0: Impaler Tzilug Enchanted Emerald.
-- Converted from ProjectEQ Perl quest script.
-- items: 10634, 10621

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10634}) then
		e.self:Say("Your bidding has been done, now leave this land and never return.")
		e.other:AddEXP(10000)
		e.other:SummonItem(10621) -- Enchanted Emerald
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
