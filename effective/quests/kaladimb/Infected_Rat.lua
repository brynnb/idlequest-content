-- Converted from ProjectEQ Perl quest script.
-- Source: kaladimb/Infected_Rat.pl

function event_waypoint_arrive(e)
	if e.wp == 5 then
		e.self:SetRunning(true)
	end
end
