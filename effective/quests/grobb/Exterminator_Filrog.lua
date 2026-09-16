-- Converted from ProjectEQ Perl quest script.
-- Source: grobb/Exterminator_Filrog.pl
-- items: 13253

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hey you dere! Look at all these spiders! Dey called me to come kill em, but there is too many!!! If you bring me four eyes from da little spiders, I reward you!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13253, item2 = 13253, item3 = 13253, item4 = 13253}) then
		e.self:Say("You good at killing spiders. Mebbe me should find anuder job. Here take da coins.")
		e.other:Faction(376, 1)
		e.other:AddEXP(100)
		e.other:GiveCash(1, 1, 1, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

