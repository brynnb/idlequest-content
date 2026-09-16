-- Converted from ProjectEQ Perl quest script.
-- Proximity-say trigger paired with tox/38139.lua.

local partone = 0

function event_spawn(e)
	local x = e.self:GetX()
	local y = e.self:GetY()
	eq.set_proximity(x - 25, x + 25, y - 25, y + 25, -999999, 999999)
	eq.enable_proximity_say()
end

function event_proximity_say(e)
	if e.message:findi("yo ho. no sun!!") then
		partone = 1
	elseif e.message:findi("a skeleton's day is never done.") and partone == 1 then
		e.other:Message(1, "Your voice echoes nicely from the walls.")
		eq.signal(38139, 1)
		partone = 0
	else
		partone = 0
	end
end
