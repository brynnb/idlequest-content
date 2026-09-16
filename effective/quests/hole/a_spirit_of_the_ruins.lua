-- Converted from ProjectEQ Perl quest script.
-- Source: hole/a_spirit_of_the_ruins.pl

local function class_gender(e)
	return e.self:GetClass(), e.self:GetGender()
end

function event_aggro(e)
	local class, gender = class_gender(e)
	if class == 1 and gender == 0 then
		e.self:Emote("glares with soulful hatred at the invaders of the ruins.")
	elseif class == 3 and gender == 0 then
		e.self:Emote("aims to touch its victim with deadly harm.")
	elseif class == 3 and gender == 1 then
		e.self:Emote("awakens the magic it has not used for some time.")
	elseif class == 1 and gender == 1 then
		e.self:Emote("raises her spectral arms and attacks.")
	else
		e.self:Say("You had best prepare yourself for the fury of the heretics!")
	end
end

function event_death_complete(e)
	local class, gender = class_gender(e)
	if class == 1 and gender == 0 then
		e.self:Emote("shrieks as his hollow ghostly form falls gently to the ground.")
	elseif class == 3 and gender == 0 then
		e.self:Emote("comfortably laughs at his own impending death.")
	elseif class == 3 and gender == 1 then
		e.self:Emote("releases her mana and soul into the air around you.")
	elseif class == 1 and gender == 1 then
		e.self:Emote("looks dazed as her bound spirit escapes.")
	else
		e.self:Say("Even with my death, you will never take the city from us!")
	end
end
