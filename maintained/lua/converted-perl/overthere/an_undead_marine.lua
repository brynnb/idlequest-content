-- Converted from ProjectEQ Perl quest script.
-- Source: overthere/an_undead_marine.pl

function event_signal(e)
	local x = e.self:GetX()
	local y = e.self:GetY()
	if (x == 2146 and y == 2445) or (x == 2151 and y == 2440) or (x == 2136 and y == 2453) or (x == 2124 and y == 2465) or (x == 2130 and y == 2459) or (x == 2142 and y == 2448) then
		e.self:Say("Sir, yes sir!!")
	end
end
