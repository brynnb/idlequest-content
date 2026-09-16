-- Converted from ProjectEQ Perl quest script.
-- Source: hole/_.pl

function event_spawn(e)
	eq.set_timer("appearance", 1000)
end

function event_timer(e)
	if e.timer == "appearance" then
		eq.stop_timer("appearance")
		e.self:SetAppearance(3)
	end
end
