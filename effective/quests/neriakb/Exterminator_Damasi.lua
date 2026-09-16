-- Converted from ProjectEQ Perl quest script.
-- Source: neriakb/Exterminator_Damasi.pl
-- items: 13071

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings, traveller. How would you like to make some money? I was brought in to kill some of these rodents that have been infesting the city but there are simply way too many of them. If you can kill some of the rodents around here and bring me four rat whiskers, perhaps I could find some spare coin for you.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13071, item2 = 13071, item3 = 13071, item4 = 13071}) then
		e.self:Say("Well there are still many rodents around but I will honor my deal. Here are your coins. Now I must get back to work.")
		e.other:Faction(370, 10, 0)
		e.other:Faction(334, 10, 0)
		e.other:Faction(270, 10, 0)
		e.other:Faction(1522, -10, 0)
		e.other:AddEXP(5)
		e.other:GiveCash(1, 1, 1, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
