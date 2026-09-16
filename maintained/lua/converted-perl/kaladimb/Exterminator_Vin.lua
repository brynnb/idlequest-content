-- Converted from ProjectEQ Perl quest script.
-- Source: kaladimb/Exterminator_Vin.pl
-- items: 13071

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello, I be Vin the Exterminator. I am here to get rid of these darn rodents that are plaguing our town. If ya would like to make a small bit of coin, perhaps you could help me. Hunt down some rodents and bring me four of their whiskers.  If yer not too busy, that is.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13071, item2 = 13071, item3 = 13071, item4 = 13071}) then
		e.self:Say("Ah ya have returned. Nice work. You might consider a career in vermin extermination yourself!")
		e.other:Faction(312, 5, 0)
		e.other:Faction(274, 5, 0)
		e.other:Faction(293, 5, 0)
		e.other:Faction(290, 5, 0)
		e.other:Faction(232, -5, 0)
		e.other:GiveCash(1, 1, 1, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_combat(e)
	if e.joined then
		e.self:Say("Say yer prayers!!")
	end
end

function event_slay(e)
	e.self:Say("Another unworthy opponent. Never cross Mining Guild 628!!")
end
