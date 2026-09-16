-- Converted from ProjectEQ Perl quest script.
-- Source: gfaydark/Merchant_Iludarae.pl
-- items: 18904, 2012, 2004, 2006, 2005, 2011

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18904}) then
		e.self:Say("I have no words for the gratitude I feel. So many of our young ones have been captured by the filthy orcs. Please, take this for saving my sister.")
		e.other:AddEXP(30000)
		e.other:Ding()
		e.other:SummonItem(eq.ChooseRandom(2012, 2004, 2006, 2005, 2011))
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
