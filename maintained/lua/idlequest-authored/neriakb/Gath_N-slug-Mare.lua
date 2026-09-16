-- IdleQuest starting guild note turn-in.
-- name: Gath_N`Mare
-- items: 18755, 13584

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18755}) then
		e.self:Say("I am Gath N'Mare, master wizard of the Tower of the Spurned. Welcome to our guild. Let's get started, shall we? Here is your tunic, represent us well with it. Good luck and study hard.")
		e.other:SummonItem(13584)
		e.other:AddEXP(100)
		e.other:Faction(363, 100, 0)
		e.other:Faction(239, -15, 0)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
