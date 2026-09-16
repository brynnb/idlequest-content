-- Converted from ProjectEQ Perl quest script.
-- Source: cazicthule/a_lifestealer_mosquito.pl

function event_aggro(e)
	if math.random(2) == 1 then
		e.self:Emote("hovers for a moment and attacks!")
	else
		e.self:Emote("buzzes towards you with horrific speed!")
	end
end

function event_death_complete(e)
	if math.random(2) == 1 then
		e.self:Emote("explodes into a fine mist of blood and plasma")
	else
		e.self:Emote("hits the ground and begins to form a large pool of blood.")
	end
end
