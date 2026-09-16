-- Converted from ProjectEQ Perl quest script.
-- Source: commons/a_Dervish_Thug.pl

function event_combat(e)
	if not e.joined then
		return
	end
	e.self:Say("Time to die " .. e.other:GetCleanName() .. "")
end
