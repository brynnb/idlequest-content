-- Converted from ProjectEQ Perl quest script.
-- Proximity zone trigger from Timorous Deep to Firiona Vie.

function event_spawn(e)
	local x = e.self:GetX()
	local y = e.self:GetY()
	eq.set_proximity(x - 35, x + 35, y - 35, y + 35)
end

function event_enter(e)
	eq.move_pc(84, 1408.9, -4334.3, -103.6)
end
