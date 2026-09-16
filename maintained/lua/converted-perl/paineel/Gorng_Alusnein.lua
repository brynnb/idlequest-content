-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Gorng_Alusnein.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Hello.  Be careful what you say to Iva.  She has been rather touchy lately.  She seems as if she is waiting for something to happen.  What. I know not.")
	end
end
