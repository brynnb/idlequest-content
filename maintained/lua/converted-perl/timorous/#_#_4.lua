-- Converted from ProjectEQ Perl quest script.
-- Proximity zone trigger from Timorous Deep to Oasis of Marr.

function event_spawn(e)
	local x = e.self:GetX()
	local y = e.self:GetY()
	eq.set_proximity(x - 65, x + 65, y - 65, y + 65)
end

function event_enter(e)
	eq.move_pc(37, -847.8, 883.6, -0.5)
end
