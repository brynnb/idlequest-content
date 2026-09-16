-- Converted from ProjectEQ Perl quest script.
-- Proximity zone trigger from The Overthere to Timorous Deep.

function event_spawn(e)
	local x = e.self:GetX()
	local y = e.self:GetY()
	eq.set_proximity(x - 75, x + 75, y - 75, y + 75)
end

function event_enter(e)
	eq.move_pc(96, 3506.0, 5702.5, 4.6)
end
