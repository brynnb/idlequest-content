-- Converted from ProjectEQ Perl quest script.
-- Source: swampofnohope/Trooper_Fodcod.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Hail. adventurer!  Watch your step and don't get lost in the swamplands.  The frogloks will have you for stew.")
	end
end
