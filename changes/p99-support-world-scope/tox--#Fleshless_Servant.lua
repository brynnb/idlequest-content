-- enabled: false
-- P99 scope: exclusive excluded chain hook. Historical callbacks retained below; see p99-support-source-review/world-scope-dispositions.json.
-- Converted from ProjectEQ Perl quest script.
-- Source: tox/#Fleshless_Servant.pl

function event_death_complete(e)
	eq.set_global("grisk", "1", 5, "f")
end
