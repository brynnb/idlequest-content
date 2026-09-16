-- Converted from ProjectEQ Perl quest script.
-- Source: qcat/Beggar_Wyllin.pl

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings!! This is no place for a person of your standards. I am but a beggar, that is why I live among the sewer rats. It would be best if you were to leave this dangerous place.")
	elseif e.message:findi("rat king") then
		e.self:Say("That is but a child's fairy tale.")
	end
end
