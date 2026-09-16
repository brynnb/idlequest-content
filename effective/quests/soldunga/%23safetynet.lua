-- Converted from ProjectEQ Perl quest script.
-- Proximity safety trigger that returns players to Solusek's Eye.

function event_spawn(e)
	local x = e.self:GetX()
	local y = e.self:GetY()
	eq.set_proximity(x - 5, x + 5, y - 5, y + 5)
end

function event_enter(e)
	eq.move_pc(31, -485, -476, 73)
end
