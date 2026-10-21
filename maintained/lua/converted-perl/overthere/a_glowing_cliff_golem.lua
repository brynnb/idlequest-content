-- Converted from ProjectEQ Perl quest script.
-- Source: overthere/a_glowing_cliff_golem.pl

function event_spawn(e)
	-- P99 Crusader's Tests: hold the defensive position for 45 minutes.
	eq.set_timer("depop", 2700000)
	eq.start(274)
end

function event_waypoint_arrive(e)
	if e.wp == 2 then
		eq.stop()
	end
end

function event_timer(e)
	if e.timer == "depop" then
		eq.depop()
	end
end
