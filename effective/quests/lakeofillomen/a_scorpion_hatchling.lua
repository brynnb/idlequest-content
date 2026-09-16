-- Converted from ProjectEQ Perl quest script.
-- Source: lakeofillomen/a_scorpion_hatchling.pl

function event_spawn(e)
	eq.set_timer("despawn", 600000)
end

function event_timer(e)
	if e.timer == "despawn" then
		eq.stop_timer("despawn")
		eq.depop()
	end
end
