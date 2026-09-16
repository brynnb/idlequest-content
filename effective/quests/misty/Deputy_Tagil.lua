-- Converted from ProjectEQ Perl quest script.
-- Source: misty/Deputy_Tagil.pl
-- items: 18013, 13240

function event_combat(e)
	e.self:Say("Time to die!")
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18013}) then
		e.self:Say("What's this? Oh dear. I am very sorry. Please take this to Uner with my apologies.")
		e.other:SummonItem(13240)
		e.other:AddEXP(100)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
