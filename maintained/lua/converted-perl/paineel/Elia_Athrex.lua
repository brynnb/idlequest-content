-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Elia_Athrex.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Hello.  Do you need something or did you merely wish to grace me with your oh-so-delightfully perfumed breath?")
	end
end
