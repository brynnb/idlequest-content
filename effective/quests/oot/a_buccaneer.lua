-- Converted from ProjectEQ Perl quest script.
-- Source: oot/a_buccaneer.pl

function event_aggro(e)
	e.self:Say("Time to die " .. e.other:GetCleanName() .. ".")
end
