-- IdleQuest epic 1.0 steps have no minimum level; preserve class and item checks.
-- Converted from ProjectEQ Perl quest script.
-- Source: lakeofillomen/Vorash.pl

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("ignores you.")
	end
end

function event_spawn(e)
	local x = e.self:GetX()
	local y = e.self:GetY()
	eq.set_proximity(x - 50, x + 50, y - 50, y + 50)
end

function event_enter(e)
	if e.other:Class() == "Monk" then
		eq.attack(e.other:GetName())
	end
end

function event_death_complete(e)
	e.self:Say("Foolish mortal! you think you have defeated me? Now, witness the true power of Rallos Zek!")
	eq.spawn2(85208, 0, 0, -542, -807, 79.12, 0) -- Xenevorash
end
