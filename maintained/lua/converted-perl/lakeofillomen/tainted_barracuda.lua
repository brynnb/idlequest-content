-- Converted from ProjectEQ Perl quest script.
-- Source: lakeofillomen/#tainted_barracuda.pl

function event_death_complete(e)
	eq.spawn2(85224, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
end
