-- Converted from ProjectEQ Perl quest script.
-- Source: gfaydark/Captain_Silverwind.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Greetings. " .. e.other:GetName() .. ".  I protect these lands in the name of the Royal Order of Koada'Vie. defenders of Felwithe.")
	end
end
