-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Derena_Leflor.pl

function event_waypoint_arrive(e)
	if e.wp == 14 or e.wp == 52 then
		e.self:SetAppearance(1)
	elseif e.wp == 28 then
		e.self:SetAppearance(4) -- kneel
	end
end
