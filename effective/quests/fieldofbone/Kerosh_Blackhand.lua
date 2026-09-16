-- Converted from ProjectEQ Perl quest script.
-- Source: fieldofbone/Kerosh_Blackhand.pl

function event_spawn(e)
	eq.set_timer("appearance", 1000)
end

function event_timer(e)
	if e.timer == "appearance" then
		e.self:SetAppearance(1)
		eq.stop_timer("appearance")
	end
end
