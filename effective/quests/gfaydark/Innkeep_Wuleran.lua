-- Converted from ProjectEQ Perl quest script.
-- Source: gfaydark/Innkeep_Wuleran.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Welcome! Why don't you browse through my selection of fine goods and pick out some things you like " .. e.other:GetName() .. "?")
	end
end
