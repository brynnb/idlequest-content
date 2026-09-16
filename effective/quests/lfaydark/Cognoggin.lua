-- Converted from ProjectEQ Perl quest script.
-- Source: lfaydark/Cognoggin.pl

function event_aggro(e)
	e.self:Say("Time to die " .. e.other:GetCleanName() .. ".")
end
