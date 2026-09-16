-- Converted from ProjectEQ Perl quest script.
-- Source: overthere/a_cliff_golem.pl

function event_signal(e)
	if e.signal == 0 then
		eq.depop_with_timer()
	end
end
