-- Converted from ProjectEQ Perl quest script.
-- Source: kaladimb/Myre.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("I am not here to chitchat dear. If you need some gear, I can help. If you want to talk, go find a tavern.")
	end
end
