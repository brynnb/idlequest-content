-- Converted from ProjectEQ Perl quest script.
-- Source: firiona/Dune.pl

function event_spawn(e)
	eq.set_timer("follow", 1000)
end

function event_timer(e)
	if e.timer == "follow" then
		eq.follow(84131)
		eq.stop_timer("follow")
	end
end
