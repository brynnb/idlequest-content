-- Converted from ProjectEQ Perl quest script.
-- Source: rathemtn/Guard_Gruilka.pl

function event_combat(e)
	if e.joined then
		e.self:Say("Time to die " .. e.other:GetCleanName() .. "!")
	end
end

function event_aggro(e)
	local class = e.other:Class()
	e.self:Say(eq.ChooseRandom(
		"it's " .. class .. " like you that insult all of Norrath!",
		class .. " like you are an affront to my senses!",
		"I really hate " .. class .. " like you!"
	))
end

function event_death_complete(e)
	e.self:Say("My comrades will avenge my death.")
end
