-- Converted from ProjectEQ Perl quest script.
-- Source: cabeast/Smithy_Ygen.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Good day!  If you wish to survive the wilds of Kunark. you had best purchase some of my wares.  Here you may find he finest metals forged by the finest smiths.")
	end
end
