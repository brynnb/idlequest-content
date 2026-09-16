-- Converted from ProjectEQ Perl quest script.
-- Source: cabwest/Trooper_Hylpik.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("You look a bit encumbered.  You should visit The Block.")
	end
end
