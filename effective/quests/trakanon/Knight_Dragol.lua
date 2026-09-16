-- Converted from ProjectEQ Perl quest script.
-- Source: trakanon/Knight_Dragol.pl

local next_location = { x = 0, y = 0, z = 0 }

function event_spawn(e)
	local locations = {
	{ x = 2559, y = 3459, z = -242.5 },
	{ x = 3361, y = 576, z = -339 },
	{ x = 2378, y = 2728, z = -349 },
	{ x = -143.8, y = -2026.8, z = -324 }
	}
	next_location = locations[math.random(#locations)]
end

function event_death_complete(e)
	local next_mob_id = eq.ChooseRandom(95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95000, 95107, 95150, 95155, 95156, 95158, 95164, 95165, 95166, 95170, 95175, 95177, 95178, 95179, 95182)
	eq.spawn2(next_mob_id, 0, 0, next_location.x, next_location.y, next_location.z, 0)
end
