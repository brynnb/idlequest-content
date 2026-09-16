-- Converted from ProjectEQ Perl quest script.
-- Source: trakanon/Flayhte.pl

local next_location = { x = 0, y = 0, z = 0 }

function event_spawn(e)
	local locations = {
	{ x = 1271.88, y = -1461.88, z = -284.75 },
	{ x = 4264.87, y = 2517, z = -334.4 },
	{ x = 1402, y = 2378, z = -235.4 },
	{ x = 3341, y = 2364, z = -331.63 },
	{ x = 1198, y = -1997, z = -311.5 },
	{ x = 1543, y = -2037, z = -319.5 }
	}
	next_location = locations[math.random(#locations)]
end

function event_death_complete(e)
	local next_mob_id = eq.ChooseRandom(95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95004, 95129, 95130, 95149, 95151, 95153, 95154, 95157, 95159, 95160, 95161, 95162, 95167, 95169, 95171, 95172, 95176)
	eq.spawn2(next_mob_id, 0, 0, next_location.x, next_location.y, next_location.z, 0)
end
