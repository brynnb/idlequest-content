-- Converted from ProjectEQ Perl quest script.
-- Source: rathemtn/Innkeep_Serge.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Welcome to the Rathe Mountains hideaway!")
	end
end
