-- Converted from ProjectEQ Perl quest script.
-- Source: qcat/a_Beggar.pl

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Guards! Guards! Help me!!")
		e.self:Say("Guards! Guards! Help me!!")
	end
end
