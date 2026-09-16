-- Converted from ProjectEQ Perl quest script.
-- Source: frontiermtns/a_human_skeleton.pl
-- items: 20475, 20476

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20475}) then
		e.self:Emote("begins to crack and disintegrate, its body collapsing into a pile of dust that scatters into the winds. On the ground you notice a locket on a fine, thin chain which you pick up.")
		e.other:SummonItem(20476)
		eq.depop_with_timer()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
