-- Converted from ProjectEQ Perl quest script.
-- Source: kaladimb/Bndainy_Everhot.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Welcome to Everhot Forge! I supply weapon molds for skilled blacksmiths. Care to view my wares?")
	end
end
