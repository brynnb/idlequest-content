-- Converted from ProjectEQ Perl quest script.
-- Source: kaladimb/Guard_Doradek.pl

function event_combat(e)
	if not e.joined then
		return
	end
	e.self:Say("Time to die " .. e.other:GetCleanName() .. "!")
end
