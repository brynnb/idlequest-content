-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Dovan_Sires.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Hrm?  Yes. yes?  Buy something. or leave me alone!")
	end
end
