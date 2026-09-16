-- IdleQuest starting guild note turn-in.
-- Source: qcat/Rocthar_Bekesna.pl
-- items: 18853, 13504

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("I've little time for banter. unless you have come to me for training as a [new warrior] of the Bloodsabers move along.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18853}) then
		e.other:SummonItem(13504)
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
