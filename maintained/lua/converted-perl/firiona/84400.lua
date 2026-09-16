-- Converted from ProjectEQ Perl quest script.
-- Proximity zone trigger from Firiona Vie to Timorous Deep.

function event_spawn(e)
	local x = e.self:GetX()
	local y = e.self:GetY()
	eq.set_proximity(x - 25, x + 25, y - 25, y + 25)
end

function event_enter(e)
	eq.move_pc(96, -3260.10, -4544.56, 19.47)
end
