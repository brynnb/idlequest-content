-- Converted from ProjectEQ Perl quest script.
-- Source: cabeast/Trooper_Keplar.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("You want to be like Trooper Keplar?  Who does not?  You must first be summoned to rebirth within Fortress Talishan.  If you have not. then you can not be like this grand one.")
	end
end
