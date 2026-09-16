-- Converted from ProjectEQ Perl quest script.
-- Source: oot/Capt_Surestout.pl

function event_death_complete(e)
	eq.spawn2(69149, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
end
