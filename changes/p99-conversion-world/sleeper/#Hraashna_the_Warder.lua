-- name: #Hraashna_the_Warder
-- Source: sources/projecteq/sleeper/#Hraashna_the_Warder.pl
-- Source SHA256: b53f968b18723252e05660ae11be973bb5cff3a9dfd2c22aff2d586d8f4e2f69
-- P99 conversion review: changes/p99-conversion-world/closure-review.json
-- Retain all three living-warder checks and signal66, without global-state shortcuts.
-- This is a complete local callback, not a functioning cross-zone awakening event.
function event_death_complete(e)
  local list = eq.get_entity_list()
  if not list:GetMobByNpcTypeID(128090).valid and not list:GetMobByNpcTypeID(128091).valid and not list:GetMobByNpcTypeID(128092).valid then eq.signal(128094, 66, 0) end
  e.self:Shout("Warders, I have fallen. Prepare yourselves, these fools are determined to unleash doom!")
end
