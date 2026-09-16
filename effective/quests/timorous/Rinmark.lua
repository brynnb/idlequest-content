-- Converted from ProjectEQ Perl quest script.
-- Source: timorous/Rinmark.pl

function event_spawn(e)
	eq.set_timer("Depop3", 90000)
end

function event_combat(e)
	if e.joined then
		eq.stop_timer("Depop3")
		e.self:Say("Good, your sense of timing is correct. Now begin! Show me that your training has not been wasted.")
	else
		eq.set_timer("Depop3", 90000)
	end
end

function event_timer(e)
	if e.timer == "Depop3" then
		eq.stop_timer("Depop3")
		eq.depop()
	end
end

function event_death_complete(e)
	e.self:Say("Your ability is strong, may you serve Cazic Thule with all your might.")
end
