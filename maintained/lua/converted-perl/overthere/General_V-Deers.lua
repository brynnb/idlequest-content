-- Converted from ProjectEQ Perl quest script.
-- Source: overthere/General_V-Deers.pl

function event_signal(e)
	if e.signal == 1 then
		eq.depop_with_timer()
	elseif e.signal == 2 then
		e.self:MoveTo(2717, 2500, -49, 130, true)
		eq.set_timer("getset", 525000)
	end
end

function event_timer(e)
	if e.timer == "getset" then
		eq.stop_timer("getset")
		e.self:Say("Dragoons!!  Attention!!  Right face!!")
		eq.start(277)
	end
end

function event_waypoint_arrive(e)
	if e.wp == 1 then
		e.self:Say("Forward.. march!!  Your left.. Your.. left, right, march!  Eighty.. second.. dragoon soldier!!  Pick up your weapon and follow me!!")
		eq.signal(93186, 3) -- #High_Priest_I`Xar
		eq.signal(93124, 3) -- Dragoon_Barber_W`Selo
		eq.signal(93088, 3) -- Dragoon_T`Vem
		eq.signal(93084, 3) -- Dragoon_T`Vex
		eq.signal(93125, 3) -- Dragoon_V`Lask
		eq.signal(93086, 3) -- Dragoon_V`Resh
	end
end
