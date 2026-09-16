-- Converted from ProjectEQ Perl quest script.
-- Source: cabeast/Trooper_Byzin.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("I have no time for conversation.  Go. and leave me to my duties.")
	end
end
