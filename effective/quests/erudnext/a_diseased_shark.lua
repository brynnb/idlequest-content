-- Converted from ProjectEQ Perl quest script.
-- Source: erudnext/a_diseased_shark.pl

function event_death_complete(e)
	local count = math.random(5, 6)
	for _ = 1, count do
		local xoff = math.random(5, 15)
		local yoff = math.random(5, 15)
		if math.random(1, 2) == 1 then
			eq.spawn2(24110, 15, 0, e.self:GetX() + xoff, e.self:GetY() + yoff, e.self:GetZ(), e.self:GetHeading()) -- a_young_shark
		else
			eq.spawn2(24110, 15, 0, e.self:GetX() - xoff, e.self:GetY() - yoff, e.self:GetZ(), e.self:GetHeading()) -- a_young_shark
		end
	end
end
