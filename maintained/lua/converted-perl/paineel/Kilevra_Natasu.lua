-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Kilevra_Natasu.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Have you spoken with Danus?  If not. I suggest you do. so that I will not waste my breath further.")
	end
end
