-- Converted from ProjectEQ Perl quest script.
-- Source: charasis/Venril_Sathir.pl

function event_death_complete(e)
	eq.unique_spawn(105187, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
end
