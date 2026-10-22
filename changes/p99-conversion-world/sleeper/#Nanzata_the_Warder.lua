-- name: #Nanzata_the_Warder
-- Source: sources/projecteq/sleeper/#Nanzata_the_Warder.pl
-- Source SHA256: 226d867c6326f9624b8aafaa654641ef1477ff9993e4bb9862697e0dc881e732
-- P99 conversion review: changes/p99-conversion-world/closure-review.json
-- Retain all three living-warder checks and signal66, without global-state shortcuts.
-- This is a complete local callback, not a functioning cross-zone awakening event.
function event_death_complete(e)
  local list = eq.get_entity_list()
  if not list:GetMobByNpcTypeID(128091).valid and not list:GetMobByNpcTypeID(128092).valid and not list:GetMobByNpcTypeID(128093).valid then eq.signal(128094, 66, 0) end
  e.self:Shout("Warders, I have fallen. Prepare yourselves, these fools are determined to unleash doom!")
end
