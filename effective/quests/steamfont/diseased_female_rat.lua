-- Converted from ProjectEQ Perl quest script.
-- Source: steamfont/diseased_female_rat.pl

function event_death_complete(e)
	eq.spawn2(56086, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
	eq.spawn2(56086, 0, 0, e.self:GetX()+5, e.self:GetY()+5, e.self:GetZ(), e.self:GetHeading())
	eq.spawn2(56086, 0, 0, e.self:GetX()+5, e.self:GetY()-5, e.self:GetZ(), e.self:GetHeading())
	eq.spawn2(56086, 0, 0, e.self:GetX()-5, e.self:GetY()+5, e.self:GetZ(), e.self:GetHeading())
	eq.spawn2(56086, 0, 0, e.self:GetX()-5, e.self:GetY()-5, e.self:GetZ(), e.self:GetHeading())
end
