-- Converted from ProjectEQ Perl quest script.
-- Source: rathemtn/Exterminator_Galub.pl
-- items: 13253

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome to Gukta. I am afraid I do not have much time to talk, my friend. Recently, the jungle hatchling population has gotten way out of control around here. I was brought in to try to curb their numbers but there are too many! Perhaps you could be of assistance to me. If you have time, kill some of the hatchlings and bring me four of their eyes. I will reward you of course.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13253, item2 = 13253, item3 = 13253, item4 = 13253}) then
		e.self:Say("Thank you for your help! But I must go, as you can see there are still many spiders for me to exterminate!")
		e.other:Faction(1709, 10, 0)
		e.other:AddEXP(5)
		e.other:GiveCash(1, 1, 1, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
