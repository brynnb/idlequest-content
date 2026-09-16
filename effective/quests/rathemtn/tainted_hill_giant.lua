-- Converted from ProjectEQ Perl quest script.
-- Source: rathemtn/tainted_hill_giant.pl

function event_death_complete(e)
	eq.spawn2(50322, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
end
