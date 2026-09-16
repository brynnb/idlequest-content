-- Converted from ProjectEQ Perl quest script.
-- Source: hole/a_spirit_of_the_old_city.pl

local function class_gender(e)
	return e.self:GetClass(), e.self:GetGender()
end

function event_aggro(e)
	local class, gender = class_gender(e)
	if class == 1 and gender == 0 then
		e.self:Say("You fail to understand our devotion to this ruined city!")
	elseif class == 3 and gender == 0 then
		e.self:Say("You will not leave here alive!  You should not have come.")
	elseif class == 3 and gender == 1 then
		e.self:Emote("glides forward with a ferocious hiss.")
	elseif class == 1 and gender == 1 then
		e.self:Say("There are no invitations to our city!")
	else
		e.self:Say("We will protect our city at all costs.")
	end
end

function event_death_complete(e)
	local class, gender = class_gender(e)
	if class == 1 and gender == 0 then
		e.self:Emote("slowly drops into a translucent heap on the ground.")
	elseif class == 3 and gender == 0 then
		e.self:Emote("drifts to the ground and dissipates")
	elseif class == 3 and gender == 1 then
		e.self:Emote("disappears into the air with an echoing cry.")
	elseif class == 1 and gender == 1 then
		e.self:Emote("fights to keep lies to the mortal realm and fails.")
	else
		e.self:Emote("attempts to grab your throat as its ghostly form fades into nothingness.")
	end
end
