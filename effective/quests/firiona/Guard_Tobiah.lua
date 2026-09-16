-- Converted from ProjectEQ Perl quest script.
-- Source: firiona/Guard_Tobiah.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Hail.  I urge you not to venture too far from the outpost.  We may not hear your cries for help.")
	end
end
