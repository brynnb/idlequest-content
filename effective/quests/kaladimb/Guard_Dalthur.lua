-- Converted from ProjectEQ Perl quest script.
-- Source: kaladimb/Guard_Dalthur.pl

function event_combat(e)
	if not e.joined then
		return
	end
	e.self:Say("Time to die " .. e.other:GetCleanName() .. "!")
end
