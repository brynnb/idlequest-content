-- Converted from ProjectEQ Perl quest script.
-- Source: neriakc/Hekzin_G-Zule.pl
-- items: 17943, 13889, 12258

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("How's it going. scrub? Correct me if I'm wrong. but you appear to be a rogue. If you're a [new rogue]. it's my job to test your skill.  If you are not. then by speaking with me. I see you show interest in [joining this house of rogues].")
	elseif e.message:findi("new rogue") or e.message:findi("joining this house of rogues") then
		e.self:Say("We of the Ebon Mask must first be sure you are skilled with a blade. At the same time. we are attempting to create a new type of armor for our rogues. So it is the test of each young rogue to take this bag into Nektulos and fill it with three moss snake skins and three snake fangs. then combine them. We get the bag and you earn a little respect as well as the [Dark Shield of Ebon].")
		e.other:SummonItem(17943)
	elseif e.message:findi("dark shield of ebon") then
		e.self:Say("The Dark Shield of Ebon was made for the use of this house by the finest craftsmen of Neriak.  It can be carried in the hand as well as slung upon one's back.  Besides this advantage. it is much lighter than most other shields.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13889}) then
		e.self:Say("Fine work for a scrub. Maybe one day you will be able to test this new snakescale armor out. For the moment you shall take the [Dark Shield of Ebon] if you do not own one already.")
		e.other:SummonItem(12258)
		e.other:GiveCash(0, 4, 0, 0)
		e.other:Faction(320, -1, 0)
		e.other:Faction(262, -1, 0)
		e.other:Faction(244, 2, 0)
		e.other:Faction(263, -1, 0)
		e.other:Faction(329, -1, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
