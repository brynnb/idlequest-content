-- Converted from ProjectEQ Perl quest script.
-- Source: cauldron/#Bilge_Farfathom.pl

function event_death_complete(e)
	local random_result = math.random(100) - 1
	if random_result < 25 then
		eq.spawn2(70060, 5, 0, -296.37, -122.31, -349.32, 244) -- an aqua goblin mariner
	elseif random_result < 50 then
		eq.spawn2(70062, 6, 0, -974.5, 436.4, -343.8, 58) -- #an_undertow_skeleton
	elseif random_result < 75 then
		eq.spawn2(70061, 7, 0, -848.3, -184.8, 216.3, 74.6) -- #aqua_goblin_shaman
	else
		eq.spawn2(70063, 8, 0, 612.6, 625.2, 209.0, 351.2) -- #a_cauldron_rat
	end
end
