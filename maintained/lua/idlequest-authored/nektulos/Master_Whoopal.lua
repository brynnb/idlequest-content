-- IdleQuest-authored P99 Classic delivery quest support.
-- P99: https://wiki.project1999.com/Letter_to_Master_Whoopal
-- items: 18957

function event_trade(e)
	local item_lib = require("items")

	if item_lib.check_turn_in(e.trade, {item1 = 18957}) then -- Leatherfoot Raider Orders
		e.self:Say("You have my gratitude for getting this note to me safely. Here are some coins as payment. I'm sorry it's all I can spare at the time. We are in need of constant supplies to hold off the assaults of the dark elves who inhabit this tainted dark forest.")
		e.other:Ding()
		e.other:Faction(286, 1, 0) -- Mayor Gubbin
		e.other:Faction(355, 1, 0) -- Storm Reapers
		e.other:Faction(292, 1, 0) -- Merchants of Rivervale
		e.other:Faction(324, -1, 0) -- Unkempt Druids
		e.other:AddEXP(100)
		e.other:GiveCash(0, 0, 1, 0)
	end

	item_lib.return_items(e.self, e.other, e.trade)
end
