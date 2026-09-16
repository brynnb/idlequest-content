-- Converted from ProjectEQ Perl quest script.
-- Source: firiona/Assistant_Buford.pl
-- items: 10059, 17045, 12829, 12940

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Well hello there. I am new to the bank. I am helping the Fargins out since it is so busy lately. Mr. Fargin doesn't even have time for his [hobby] these days.")
	elseif e.message:findi("hobby") then
		e.self:Say("'Mr. Fargin used to collect rare coins and gems. He came to Firiona Vie to do just that, but now he never has the time to [collect rare coins] since he is always working here. That is why I came to help him out.")
	elseif e.message:findi("collect rare coins") then
		e.self:Say("If you want to help, you can begin by replacing Mr. Fargin's prized Star of Odus which was taken from his vault when he stepped out to dine one night. Do so, and I may trust you to collect coins. I will also reward you with an item a composer left here. With Mr. Fargin's approval of course.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10059}) then
		e.self:Say("Thank you!! I never could have gone to Odus to replace this. Perhaps now you can collect some rare coins.")
		e.other:SummonItem(17045)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12829}) then
		e.self:Say("Great!! Now, my collection is almost complete. Here is a gift. A composer accidently left behind a crate of these, perhaps it can be of some use to you.")
		e.other:SummonItem(12940)
		e.other:Ding()
		e.other:Faction(1022, 10, 0) -- Firiona Vie
		e.other:Faction(326, 10, 0) -- Emerald Warriors
		e.other:Faction(312, 10, 0) -- Storm Guard
		e.other:Faction(441, -10, 0) -- Legion of Cabilis
		e.other:Faction(313, -10, 0) -- Pirates of Gunthak
		e.other:AddEXP(10000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
