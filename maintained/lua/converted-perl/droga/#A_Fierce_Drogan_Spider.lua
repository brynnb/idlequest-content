-- Converted from ProjectEQ Perl quest script.
-- Source: droga/v1/#A_Fierce_Drogan_Spider.pl

function event_combat(e)
	e.self:Emote("quickly skitters towards its prey.")
end

function event_death_complete(e)
	e.self:Emote("'s corpse explodes in a large spray of ichor as it is squashed for good..")
end
