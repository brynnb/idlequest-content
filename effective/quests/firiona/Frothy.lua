-- Converted from ProjectEQ Perl quest script.
-- Source: firiona/Frothy.pl

function event_say(e)
	if e.message:findi("what jungle city") then
		e.self:Say("I've heard adventurers talk of a city deep in the jungles.  They say the dead walk its streets.  Many have claimed to discover great treasures there as well as to lose many friends.  I also heard it may have a working brew barrel.")
	end
end
