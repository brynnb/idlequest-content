-- Converted from ProjectEQ Perl quest script.
-- Source: neriakc/Exterminator_Gilea.pl
-- items: 13071

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello, " .. e.other:GetName() .. ". I was hired to eradicate all these pesky rodents running around the city, but there are too many of them. If you could help me by bringing back four of their whiskers I should have a few spare coins for you.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13071, item2 = 13071, item3 = 13071, item4 = 13071}) then
		e.self:Say("Well there are still many rodents around, but I will honor my deal. Here are your coins. Now I must get back to work.")
		e.other:Faction(370, 10, 0)
		e.other:Faction(236, 10, 0)
		e.other:Faction(270, 10, 0)
		e.other:Faction(1522, -10, 0)
		e.other:AddEXP(5)
		e.other:GiveCash(1, 1, 1, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
