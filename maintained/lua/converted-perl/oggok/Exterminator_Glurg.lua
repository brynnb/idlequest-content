-- Converted from ProjectEQ Perl quest script.
-- Source: oggok/Exterminator_Glurg.pl
-- items: 19195

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello dere. Do you see all dese darn critters running around here? Dere are little armadillos everywhere! We need to git rid of dem. If you bring me four of dere husks, I pay you money. Too many for me to smash alone.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 19195, item2 = 19195, item3 = 19195, item4 = 19195}) then
		e.self:Say("You smashed dem gud. Take dese coins!")
		e.other:Faction(337, 10, 0)
		e.other:Faction(374, 10, 0)
		e.other:Faction(228, 10, 0)
		e.other:AddEXP(500)
		e.other:GiveCash(1, 1, 1, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
