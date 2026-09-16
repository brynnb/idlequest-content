-- Converted from ProjectEQ Perl quest script.
-- Source: swampofnohope/Flighty_Violet_Wisp.pl

function event_spawn(e)
	eq.set_timer("depop", 600000)
end

function event_timer(e)
	if e.timer == "depop" then
		eq.stop_timer("depop")
		eq.depop()
	end
end

function event_combat(e)
	if e.joined then
		eq.stop_timer("depop")
	else
		eq.set_timer("depop", 600000)
	end
end

function event_death_complete(e)
	eq.stop_timer("depop")
end
