-- Converted from ProjectEQ Perl quest script.
-- Source: overthere/a_glowing_cliff_golem.pl

function event_spawn(e)
	eq.set_timer("depop", 640000)
	eq.start(274)
end

function event_timer(e)
	if e.timer == "depop" then
		eq.depop()
	end
end
