-- Converted from ProjectEQ Perl quest script.
-- Proximity zone trigger from Timorous Deep to The Overthere.

function event_spawn(e)
	local x = e.self:GetX()
	local y = e.self:GetY()
	eq.set_proximity(x - 65, x + 65, y - 65, y + 65)
end

function event_enter(e)
	eq.move_pc(93, 2736.0, 3438.8, -158.6)
end
