-- Converted from ProjectEQ Perl quest script.
-- Source: overthere/#an_undead_marine.pl

function event_spawn(e)
	eq.set_timer("depop", 640000)
end

function event_timer(e)
	if e.timer == "depop" then
		eq.depop()
	end
end
