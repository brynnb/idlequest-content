-- Converted from ProjectEQ Perl quest script.
-- Source: nektulos/Sergeant_C-Orm.pl

local function class_insult(e)
	local class = e.other:Class()
	e.self:Say(eq.ChooseRandom(
		class .. " like you are an affront to my senses!",
		class .. " like you always bring out the worst in me!",
		"It's " .. class .. " like you that insult all of Norrath!"
	))
end

function event_combat(e)
	if e.joined then
		e.self:Say("Time to die " .. e.other:GetCleanName() .. "!")
	end
end

function event_aggro(e)
	class_insult(e)
end
