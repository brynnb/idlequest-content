-- Converted from ProjectEQ Perl quest script.
-- Source: sebilis/#froglok_krup_knight.pl

function event_death_complete(e)
	if math.random(10) ~= 1 then
		return
	end
	eq.spawn2(89182, 0, 0, 546, -592, -50, 128)
end
