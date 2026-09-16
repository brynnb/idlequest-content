-- IdleQuest starting guild note turn-in.
-- name: Jayna_D`Bious
-- items: 18754, 13584

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18754}) then
		e.self:Say("Welcome, young magician. I am Jayna D'Bious. You have much to learn, so let's get you started. Here is your guild tunic.")
		e.other:SummonItem(13584)
		e.other:AddEXP(100)
		e.other:Faction(363, 100, 0)
		e.other:Faction(239, -15, 0)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
