-- Converted from ProjectEQ Perl quest script.
-- Source: soldunga/Marfen_Binkdirple.pl
-- items: 20372, 20370

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20372}) then
		e.self:Say("Ah! 'Bout time ye got yer lazy bones down here! I was beginnin' ta worry bout ya. Thought ye'd never pick the doll up. Me kin worked and toiled over this thing fer days. That Baenar was sure exact in every detail. For a special child, he said. Must be some child. He spent all he had and some he didn't. Still owes us a show! Anyway, I heard she passed away some time ago. Give the lad muh regards.")
		e.other:SummonItem(20370) -- Mechanical Doll
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

