-- Converted from ProjectEQ Perl quest script.
-- Proximity zone trigger from Erudin to Erud's Crossing.

function event_spawn(e)
	local x = e.self:GetX()
	local y = e.self:GetY()
	eq.set_proximity(x - 40, x + 40, y - 40, y + 40)
end

function event_enter(e)
	eq.move_pc(98, 716.9, -1771.8, 3.2)
end
