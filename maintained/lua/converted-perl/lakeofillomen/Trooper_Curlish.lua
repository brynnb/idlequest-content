-- Converted from ProjectEQ Perl quest script.
-- Source: lakeofillomen/Trooper_Curlish.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Have you tried to drink from the lake?  It is poisoned with salt!  If you plan on venturing to the far side of the lake, you had best visit one of the Kloks to purchase a Water Extractor.")
	end
end
