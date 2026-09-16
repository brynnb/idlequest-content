-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Velana_Kelmuza.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Hello there. " .. e.other:GetName() .. ". I hope you are faring well this day.")
	end
end
