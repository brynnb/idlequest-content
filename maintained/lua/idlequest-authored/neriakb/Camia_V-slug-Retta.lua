-- IdleQuest starting guild note turn-in.
-- name: Camia_V`Retta
-- items: 18753, 13584

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18753}) then
		e.self:Say("Greetings, and welcome to the Tower of the Spurned! I am Camia V'Retta, master enchantress. Here is your guild tunic, wear it with pride.")
		e.other:SummonItem(13584)
		e.other:AddEXP(100)
		e.other:Faction(363, 100, 0)
		e.other:Faction(239, -15, 0)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
