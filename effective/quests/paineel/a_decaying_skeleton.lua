-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/a_decaying_skeleton.pl

function event_say(e)
	if e.message:findi("Ahhh, I feel much better now...") then
		e.self:Say("Arrrreeeee!")
	end
end
