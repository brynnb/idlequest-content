-- Converted from ProjectEQ Perl quest script.
-- Source: kaladima/Guard_Adolmer.pl

function event_waypoint_arrive(e)
	if e.wp == 4 then
		e.self:SetAppearance(4) -- kneel
	end
end
