-- Converted from ProjectEQ Perl quest script.
-- Source: commons/a_Dervish_Cutthroat.pl

function event_combat(e)
	if not e.joined then
		return
	end
	if e.self:GetRace() == 54 then
		e.self:Say("Orc stomp, orc kill - orc weapons, your blood will spill.")
	else
		e.self:Say("Time to die " .. e.other:GetCleanName() .. "!")
	end
end
