-- Converted from ProjectEQ Perl quest script.
-- Source: lavastorm/v1/Brunnel_Kegstander.pl
-- items: 7882, 7885, 7886, 7888, 7889, 7890, 7891, 7892, 7893, 7894, 7895, 7896, 7897, 7898, 7899, 7900, 7901

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("ello there. I set sail from me home on a quest and I be happy to report I've had me a bit o' success! I found me the secret to making [Forged Firebrand Weapons]. It's me own secret though and I ain't tellin")
	elseif e.message:findi("forged firebrand weapons") then
		e.self:Say("Oh, I'll tell ye about them that's for sure! They have in 'em the very power of fire! I'm a brewer by trade that's for sure but I decided to take up smithin' as me livelihood after I came across the secret. It's me own secret by the way. Think ye'd be willin' to do a [bit of trading] with me?")
	elseif e.message:findi("bit of trading") then
		e.self:Say("Well that's a might nice of ye! Ye bring me a Fiery Ore, some Imp Blood and an Essence of Fire. I uh. . . I just like collectin' them things, they have nuthin to do with me recipe. Anyway, I'll trade ye fer whatever weapon I have.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 7882, item2 = 7885, item3 = 7886}) then
		e.self:Say("Well Brell bless ya! These are great, here take this one.")
		e.other:SummonItem(eq.ChooseRandom(7888, 7889, 7890, 7891, 7892, 7893, 7894, 7895, 7896, 7897, 7898, 7899, 7900, 7901))
		e.other:Ding()
	else
		e.self:Say("I have no use for this, " .. e.other:GetName() .. ".")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
