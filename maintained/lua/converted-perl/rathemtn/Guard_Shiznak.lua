-- Converted from ProjectEQ Perl quest script.
-- Source: rathemtn/Guard_Shiznak.pl

function event_combat(e)
	if e.joined then
		e.self:Say("Time to die " .. e.other:GetCleanName() .. "!")
	end
end

function event_aggro(e)
	e.self:Say(e.other:Race() .. " have no place in our realm!")
end

function event_death_complete(e)
	e.self:Say("My comrades will avenge my death.")
end
