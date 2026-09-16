-- Converted from ProjectEQ Perl quest script.
-- Source: swampofnohope/Trooper_Harkee.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("If you find yourself deep in the swamp and starving. try foraging.  I am sure you'll find something to eat.  If not. there are always froglok tongues.")
	end
end
