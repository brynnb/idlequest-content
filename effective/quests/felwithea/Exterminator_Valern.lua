-- Converted from ProjectEQ Perl quest script.
-- Source: felwithea/Exterminator_Valern.pl
-- items: 13071

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello. Nice day, isn't it? It would be nicer if I didnt have to spend it killing these disgusting rodents that have infested town. Hey, I have an idea! How about you go kill some of them for me and collect four of their whiskers? I will reward you, of course.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13071, item2 = 13071, item3 = 13071, item4 = 13071}) then
		e.self:Say("Here are you coins as promised. Have a nice day. I wish I could.")
		e.other:Faction(325, 5)
		e.other:Faction(5001, 5)
		e.other:GiveCash(1, 1, 1, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

