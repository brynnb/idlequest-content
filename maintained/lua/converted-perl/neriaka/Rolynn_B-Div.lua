-- Converted from ProjectEQ Perl quest script.
-- Source: neriaka/Rolynn_B-Div.pl

function event_say(e)
	if e.message:findi("narex") then
		e.self:Say("Talk to Head Master Narex of the Indigo Brotherhood. He will tell you.")
	end
end

function event_waypoint_arrive(e)
	if e.wp == 3 or e.wp == 8 or e.wp == 18 then
		e.self:Say("Hear yee. Master Narex of the Indigo Brotherhood is offering one gold piece for every Leatherfoot Raider skullcap.")
	end
end
