-- Converted from ProjectEQ Perl quest script.
-- Source: kaladimb/Aanina_Rockfinder.pl
-- items: 20879, 20880

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20879}) then
		e.self:Say("Ah, nice of you to come and pick this up for Ganelorn! I know he is a busy fellow. I certainly hope that his girlfriend will like this gift.")
		e.other:SummonItem(20880)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
