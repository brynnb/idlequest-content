-- Converted from ProjectEQ Perl quest script.
-- Source: cauldron/#aqua_goblin_mariner.pl

local mdied = 0

function event_death_complete(e)
	if mdied ~= 1 then
		eq.spawn2(70060, 5, 0, -296.37, -122.31, -349.32, 244) -- an aqua goblin mariner
		mdied = 1
	end
end
