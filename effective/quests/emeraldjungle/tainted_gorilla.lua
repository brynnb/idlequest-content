-- Converted from ProjectEQ Perl quest script.
-- Source: emeraldjungle/#tainted_gorilla.pl

function event_death_complete(e)
	eq.spawn2(94140, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
end
