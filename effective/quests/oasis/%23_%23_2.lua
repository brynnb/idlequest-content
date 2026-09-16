-- Converted from ProjectEQ Perl quest script.
-- Proximity zone trigger from Oasis of Marr to Timorous Deep.

function event_spawn(e)
	local x = e.self:GetX()
	local y = e.self:GetY()
	eq.set_proximity(x - 50, x + 50, y - 50, y + 50)
end

function event_enter(e)
	eq.move_pc(96, 3335.5, 7121.4, -5.5)
end
