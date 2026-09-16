-- Converted from ProjectEQ Perl quest script.
-- Source: oggok/Grevak.pl
-- P99: https://wiki.project1999.com/Lizard_Tails_No_2
-- P99: https://wiki.project1999.com/Lizard_Dolls
-- items: 13354, 13367, 17005, 15340, 15235, 15491, 2129, 2131, 2133, 2134

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Need new members we do not. Powerful enough are we with Grevak. Still. peons needed. Are you a [new peon] or are you an [outsider]? Speak up!! Fool!! No time Grevak has!!")
	elseif e.message:findi("i am a new peon") then
		e.self:Say("So you think you can be greater than Grevak!! Touch you not and still I can smash you. I am a Greenblood shadowknight!! Peon are you. Peons go to swamps and slay lizardmen. You return with four lizardmen tails and a reward is yours. You return with two lizardman shaman dolls and a great reward is yours.")
	elseif e.message:findi("i am an outsider") then
		e.self:Say("Go away or soon your pain will find you.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13354, item2 = 13354, item3 = 13354, item4 = 13354}) then
		e.self:Say("Hmph! You still not as great as Grevak!! But you do gud. Here.")
		e.other:SummonItem(eq.ChooseRandom(2129, 2131, 2133, 2134))
		e.other:GiveCash(0, 6, 0, 0)
		e.other:AddEXP(500)
		e.other:Faction(228, 10, 0)
		e.other:Faction(261, 20, 0)
		e.other:Faction(274, -10, 0)
		e.other:Faction(308, -20, 0)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 13367, item2 = 13367}) then
		e.self:Say("You no getting big head!! Me still bash you gud! You no longer peon....you BIG peon now! Har! Har!......ok den, here great reward.")
		e.other:SummonItem(eq.ChooseRandom(17005, 15340, 15235, 15491))
		e.other:GiveCash(0, 0, 4, 0)
		e.other:AddEXP(500)
		e.other:Faction(228, 10, 0)
		e.other:Faction(261, 20, 0)
		e.other:Faction(274, -10, 0)
		e.other:Faction(308, -20, 0)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
