-- Converted from ProjectEQ Perl quest script.
-- Source: nektulos/Hetha_V-Syph.pl

function event_spawn(e)
	eq.set_timer("try_sit", 5000)
end

function event_timer(e)
	if e.timer == "try_sit" then
		e.self:SetAppearance(1)
	end
end

function event_death_complete(e)
	eq.stop_timer("try_sit")
end
