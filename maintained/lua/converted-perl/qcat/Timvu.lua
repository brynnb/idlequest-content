-- Converted from ProjectEQ Perl quest script.
-- Source: qcat/Timvu.pl

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("We are only here to finish off any enemies of the Circle who escape the sharks.")
	end
end
