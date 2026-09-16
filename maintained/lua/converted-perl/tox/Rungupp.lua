-- Converted from ProjectEQ Perl quest script.
-- Source: tox/Rungupp.pl

function event_waypoint_arrive(e)
	if e.wp == 2 then
		e.self:SetRunning(true)
	end
end
