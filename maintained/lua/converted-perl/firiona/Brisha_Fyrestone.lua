-- Converted from ProjectEQ Perl quest script.
-- Source: firiona/Brisha_Fyrestone.pl

function event_say(e)
	if e.message:findi("special fire emerald") then
		e.self:Say("Why would you want one of those? Not many people request them, except in special cases. Even you with all your powers can't tell the difference between them. Simply give Drake any fire emerald that you may have and he will make sure you get the special one.")
	end
end
