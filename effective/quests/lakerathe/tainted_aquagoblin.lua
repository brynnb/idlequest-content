-- Converted from ProjectEQ Perl quest script.
-- Source: lakerathe/#tainted_aquagoblin.pl

function event_death_complete(e)
	eq.unique_spawn(51149, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
end
