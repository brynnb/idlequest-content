-- IdleQuest starting guild note turn-in.
-- Source: qcat/Lyris_Moonbane.pl
-- items: 18721, 13552

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18721}) then
		e.self:Say("A new initiate always pleases me, here is your tunic.")
		e.other:SummonItem(13552)
		e.other:AddEXP(100)
		e.other:Faction(221, 100, 0)
		e.other:Faction(262, -15, 0)
		e.other:Faction(296, 10, 0)
		e.other:Faction(341, -25, 0)
		e.other:Faction(230, 5, 0)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
