-- Source: hole/#High_Scale_Kirn.pl
-- Shaman Epic 1.0: attackable High Scale Kirn.
-- Converted from ProjectEQ Perl quest script.

function event_spawn(e)
	-- The spawn belongs to the quest owner. Preserve the original attack; test
	-- setup must not substitute for the encounter promised by the hand-in.
	if e.other:GetClassName() == "Shaman" then
		eq.attack(e.other:GetName())
	end
end
