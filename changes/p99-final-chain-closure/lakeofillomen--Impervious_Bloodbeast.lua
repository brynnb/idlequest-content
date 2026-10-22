-- enabled: false
-- Post-Velious exact chain; complete historical callback body retained.
-- Evidence: changes/p99-final-chain-closure/review.json
-- Converted from ProjectEQ Perl quest script.
-- Source: lakeofillomen/Impervious_Bloodbeast.pl

function event_death_complete(e)
	eq.signal(85091, 0) -- Lingering_Axefall
end
