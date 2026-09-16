-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Leovre_Kieqmarn.pl

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Good day. " .. e.other:GetName() .. ".  Feel free to look through my inventory of spells. but if you touch anything without first buying it I. will have your skin pulled from your flesh. Slowly.")
	end
end
