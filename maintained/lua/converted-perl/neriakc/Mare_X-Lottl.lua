-- Source: neriakc/Mare_X-Lottl.pl
-- Converted from ProjectEQ Perl quest script.
-- items: 10020, 54026

local dance_count = 0

function event_combat(e)
	if e.joined then
		e.self:Say("Guards! Guards!")
	end
end

function event_waypoint_arrive(e)
	if e.wp == 10 then
		e.self:Say("Yoohoo!")
	end
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello there. sweetie!!  How about letting me dance for you?  Two gold and I will do a little dance for you.")
	elseif e.message:findi("tayla") then
		e.self:Say("Why do you seek that little scamp when you have Mare right here? If you really want to know where she is, it will cost you. Did I ever tell you that my heart belongs to Jasper?")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10020}) then -- Jasper
		e.self:Say("Jasper! My one and only love! All right.. That Tayla creature was lost in a game of King's Court with a very important and secret merchant. Belyea will not speak of him but that he was some sort of Baron. He did give me this trinket from his new friend and owner of the half-elf scamp. You keep it. It is worth nothing compared to sweet, beautiful Jasper.")
		e.other:SummonItem(54026) -- Klok's Seal
	elseif item_lib.check_turn_in(e.trade, {gold = 2}) then
		e.self:Say("Oooh yes!! I just love a patron with an over abundance of gold.")
		eq.set_timer("dance", 3000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_timer(e)
	if e.timer == "dance" then
		dance_count = dance_count + 1
		if dance_count < 5 then
			e.self:DoAnim(eq.ChooseRandom(28, 36, 40, 42, 51, 52, 53, 58, 60, 62, 64, 70))
		else
			eq.stop_timer("dance")
			dance_count = 0
		end
	end
end

function event_death_complete(e)
	e.self:Say("The death of a Dark Bargainer never goes unnoticed!")
end
