-- Converted from ProjectEQ Perl quest script.
-- Source: rathemtn/Blinde_the_Cutpurse.pl

function event_death_complete(e)
	eq.spawn2(50306, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
end
