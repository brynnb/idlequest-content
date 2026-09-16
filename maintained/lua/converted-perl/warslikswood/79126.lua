-- Converted from ProjectEQ Perl quest script.
-- Source: warslikswood/79126.pl

function event_spawn(e)
	eq.set_timer("depop", 600000)
end

function event_timer(e)
	if e.timer == "depop" then
		eq.stop_timer("depop")
		e.self:Shout("If you thought you could dawdle, you were not right. Because you're lazy, you lost the chance to fight.")
		eq.depop()
	end
end

function event_death_complete(e)
	eq.stop_timer("depop")
end
