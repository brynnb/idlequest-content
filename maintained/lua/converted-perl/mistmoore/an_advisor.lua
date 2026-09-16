-- Converted from ProjectEQ Perl quest script.
-- Source: mistmoore/an_advisor.pl

function event_say(e)
	if e.message:findi("hail") then
		eq.attack(e.other:GetName())
	end
end

-- P99: killing the advisor summons Black Dire in the blood-hound canyon.
-- The upstream Perl omitted this event and supplied an unconditional placement.
-- Coordinates/heading retain that imported placement (spawn2 7386); migration
-- 141 disables its automatic population without deleting the source record.
function event_death_complete(e)
	eq.spawn2(59129, 0, 0, -164, 89, -220.880005, 113)
end
