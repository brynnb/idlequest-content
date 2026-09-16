-- IdleQuest starting guild note turn-in.
-- Source: neriakc/Nezzka_Tolax.pl
-- items: 18757, 13586

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18757}) then
		e.self:Say("Hmmm, I hope you're tougher than you look. Here, put this on. There's no turning back now, punk. So, you'd better do well, got it?")
		e.other:SummonItem(13586)
		e.other:AddEXP(100)
		e.other:Faction(239, 100, 0)
		e.other:Faction(303, 15, 0)
		e.other:Faction(278, -15, 0)
		e.other:Faction(275, -15, 0)
		e.other:Faction(245, -15, 0)
		e.other:Faction(1522, -200, 0)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
