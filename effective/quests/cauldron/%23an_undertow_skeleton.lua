-- Converted from ProjectEQ Perl quest script.
-- Source: cauldron/#an_undertow_skeleton.pl

function event_death_complete(e)
	if math.random(100) <= 90 then
		eq.spawn2(70060, 6, 0, -974.5, 436.4, -343.8, 58) -- an aqua goblin mariner
	else
		eq.spawn2(70059, 4, 0, -1123.30, -1194.57, -98.32, 244) -- Bilge Farfathom
	end
end
