-- Converted from ProjectEQ Perl quest script.
-- Source: timorous/a_dancing_skeleton.pl
-- items: 17037

function event_say(e)
	if e.message:findi("gomoz") then
		e.self:Emote("stops in suprise.")
		e.self:Say("Gomoz!! Why, that is me! I was heading off to be with the elements when I was captured by this smelly ogre. Actually, he is not as smelly as most.")
		eq.stop_timer("10")
		eq.stop_timer("11")
		eq.stop_timer("12")
		eq.stop_timer("100")
		eq.set_timer("100", 40000)
	elseif e.message:findi("talon southpaw") then
		e.self:Say("Master Talon Southpaw!! He was my master. Dead, he became. Off to the elements. I keep his special hand with me. Perhaps I should have it returned. Maybe I shall find a young adventurer to [return the hand to Cabilis].")
		eq.stop_timer("100")
		eq.set_timer("100", 30000)
	elseif e.message:findi("return the hand to cabilis") then
		e.self:Say("Yes!! Return the hand. Here it is. Missing four it is. Within the tower of past pain and torture is where the four lie. Taken by bones similar to myself.")
		e.other:SummonItem(17037)
		eq.set_timer("100", 4000)
	end
end

function event_signal(e)
	if e.signal == 5 then
		eq.set_timer("10", 2000)
		e.self:Emote("shambles to its feet and begins to jig somewhat grudingly.")
	end
end

function event_timer(e)
	if e.timer == "10" then
		eq.stop_timer("10")
		eq.set_timer("11", 2000)
		e.self:DoAnim(58)
	elseif e.timer == "11" then
		eq.stop_timer("11")
		eq.set_timer("12", 2000)
		e.self:DoAnim(45)
	elseif e.timer == "12" then
		eq.stop_timer("12")
		eq.set_timer("13", 2000)
		e.self:DoAnim(58)
	elseif e.timer == "13" then
		eq.stop_timer("13")
		eq.set_timer("100", 2000)
		e.self:DoAnim(16)
	elseif e.timer == "100" then
		eq.stop_timer("100")
		eq.depop_with_timer()
	end
end
