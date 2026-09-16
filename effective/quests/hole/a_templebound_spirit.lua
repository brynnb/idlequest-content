-- Converted from ProjectEQ Perl quest script.
-- Source: hole/a_templebound_spirit.pl

local function class_gender(e)
	return e.self:GetClass(), e.self:GetGender()
end

function event_aggro(e)
	local class, gender = class_gender(e)
	if class == 1 and gender == 0 then
		e.self:Emote("I will peel your skin with my claws for this intrusion!")
	elseif class == 3 and gender == 0 then
		e.self:Emote("drifts threateningly toward its enemies.")
	elseif class == 3 and gender == 1 then
		e.self:Say("You will be enveloped by the arms of death!")
	elseif class == 1 and gender == 1 then
		e.self:Emote("attacks with her arms outstretched.")
	end
end

function event_death_complete(e)
	local class, gender = class_gender(e)
	if class == 1 and gender == 0 then
		e.self:Emote("floats to the floor as her spirit perishes")
	elseif class == 3 and gender == 0 then
		e.self:Emote("wails as his corpse is torn free.")
	elseif class == 3 and gender == 1 then
		e.self:Emote("twists and rolls as her dark soul passes on.")
	elseif class == 1 and gender == 1 then
		e.self:Emote("feels her spirit ebbing and shrieks with fear.")
	end
end
