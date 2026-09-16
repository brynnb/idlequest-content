-- Modified from ProjectEQ Lua to align Jillin's Stew faction/reward details with P99.
-- Source: rivervale/Deputy_Lowmot.lua
-- items: 13959

function event_say(e)
	if e.message:findi("nice hat") then
		e.self:Say("Thank you, It is worn with pride and is the symbol of the Rivervale Militia")
	end
end

function event_trade(e)
	local item_lib = require("items")

	if item_lib.check_turn_in(e.trade, {item1 = 13959}) then
		e.self:Say("Oh good! Hey. You are not Jillin.. Helping out Blinza huh? She is quite a woman.. Yes indeed. Quite a woman.. ah.. Oh sorry. Here you go. Thanks again. Mayor Gubbin will be pleased.")
		e.other:GiveCash(math.random(2, 6), math.random(1, 4), 0, 0)
		e.other:Faction(355, 5, 0) -- Storm Reapers
		e.other:Faction(286, 1, 0) -- Mayor Gubbin
		e.other:Faction(292, 1, 0) -- Merchants of Rivervale
		e.other:Faction(324, -1, 0) -- Unkempt Druids
		e.other:AddEXP(10)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
