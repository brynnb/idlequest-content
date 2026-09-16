-- Converted from ProjectEQ Perl quest script.
-- Source: swampofnohope/Trooper_Lorgen.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("It is assumed that the froglok stronghold is well defended. None of the troopers sent from this garrison to find it have ever returned.  At least. not in one piece.")
	end
end
