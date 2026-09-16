-- Converted from ProjectEQ Perl quest script.
-- Source: fieldofbone/#an_iksar_manslayer.pl

function event_death_complete(e)
	eq.spawn2(78211, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
end
