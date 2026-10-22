-- enabled: false
-- Post-Velious exact chain; complete historical callback body retained.
-- Evidence: changes/p99-final-chain-closure/review.json
-- Converted from ProjectEQ Perl quest script.
-- Source: lakerathe/#Gnoll_Scavenger.pl

function event_death_complete(e)
	eq.signal(51156, 0) -- Worboli / Man-eating Freshwater Shark
end
