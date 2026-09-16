-- Converted from ProjectEQ Perl quest script.
-- Source: soltemple/80021.pl

function event_say(e)
	if e.message:findi("solusek ro") then
		e.self:Say("Solusek Ro is the Master of Fire and the Keeper of Power.")
	end
end
