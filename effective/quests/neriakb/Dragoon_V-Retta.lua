-- Converted from ProjectEQ Perl quest script.
-- Source: neriakb/Dragoon_V-Retta.pl

local count = 0

function event_spawn(e)
	eq.set_timer("checks", 120000)
end

function event_timer(e)
	count = count + 1
	local hour = eq.get_zone_time().zone_hour
	if count == 1 and (hour > 8 or hour < 20) then
		eq.start(35)
	elseif count == 1 then
		eq.stop()
		e.self:MoveTo(-639, -85, -24.75, 33)
	elseif count == 2 then
		eq.set_timer("checks", 120000)
		count = 0
	end
end
