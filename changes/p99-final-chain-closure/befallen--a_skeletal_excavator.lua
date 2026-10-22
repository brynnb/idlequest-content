-- enabled: false
-- Post-Velious exact chain; complete historical callback body retained.
-- Evidence: changes/p99-final-chain-closure/review.json
function event_death_complete(e)
	local chance_spawn = math.random(100);
	if chance_spawn <= 20 then
		eq.unique_spawn(36092,0,0,-43.5,-339.8,-10.9,0);
	end
end