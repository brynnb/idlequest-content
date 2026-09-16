-- Converted from ProjectEQ Perl quest script.
-- Source: misty/Deputy_Eigon.pl
-- items: 16165

function event_combat(e)
	e.self:Say("Time to die!")
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 16165}) then
		e.self:Say("Daleen sent you? She is so sweet. If she wasn't married.. ehem.. Thanks.")
		e.other:Faction(263, 5, 0)
		e.other:Faction(286, 5, 0)
		e.other:Faction(355, 5, 0)
		e.other:Faction(292, 5, 0)
		e.other:Faction(334, -10, 0)
		e.other:GiveCash(0, 0, 1, 0)
		e.other:AddEXP(500)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
