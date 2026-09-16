-- IdleQuest starting guild note turn-in.
-- Source: grobb/Daboo_Dogak.pl
-- items: 36002, 36008

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 36002}) then
		e.self:Say("Ok I tink you strong enough to start training wit us. I gots some gud stuffs for you, little berserker! You smart to join Dethslashers guild.")
		e.other:SummonItem(36008)
		e.other:AddEXP(100)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
