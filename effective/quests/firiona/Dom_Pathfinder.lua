-- Converted from ProjectEQ Perl quest script.
-- Source: firiona/Dom_Pathfinder.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Whoa!!  Hold up there. adventurer!  Gaze upon the fine packs and containers I have available.  Such fine items could only be crafted by a Fier'Dal tailor.  And lucky you!!  You made it here just as I lowered my prices.  How can you resist these bargains?  I am taking a loss here!!  Last day!!  Buy now!!")
	end
end
