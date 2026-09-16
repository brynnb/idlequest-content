-- IdleQuest starting guild note turn-in.
-- Source: neriakc/Xon_Quexill.pl
-- items: 18758, 13587

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18758}) then
		e.self:Say("Just what I need in this outfit, another waste of flesh. Here, put this on. Return to me when you have become more experienced in our art. You'd better prove yourself of value to me. I hear I can get few platinum for the skull of an idiot on the black market, and I could make a fortune from your type. Now, get outta here!")
		e.other:SummonItem(13587)
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
