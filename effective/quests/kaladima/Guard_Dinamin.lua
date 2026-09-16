-- Converted from ProjectEQ Perl quest script.
-- Source: kaladima/Guard_Dinamin.pl

function event_waypoint_arrive(e)
	if e.wp == 6 or e.wp == 21 then
		e.self:SetAppearance(4) -- kneel
	end
end
