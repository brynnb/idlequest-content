-- IdleQuest starting guild note turn-in.
-- Source: oggok/#Bordag.pl
-- items: 18846, 13575

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18846}) then
		e.self:Say("You strong and mean like bear! You wear bear fur so all know you beastlord o' da Feerrott! Talk to Grapok and get to work!")
		e.other:SummonItem(13575)
		e.other:AddEXP(100)
		e.other:Faction(394, 15, 0)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
