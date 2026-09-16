-- Converted from ProjectEQ Perl quest script.
-- Source: overthere/Dragoon_V-Resh.pl

function event_signal(e)
	if e.signal == 1 then
		eq.depop_with_timer()
	elseif e.signal == 2 then
		e.self:MoveTo(2734, 2464, -49, 390, true)
	elseif e.signal == 3 then
		e.self:SetRunning(true)
		eq.start(281)
	end
end

function event_waypoint_arrive(e)
	if e.wp == 28 then
		e.self:SetRunning(false)
	end
end
