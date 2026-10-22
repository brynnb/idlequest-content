-- name: A_Guardian_of_the_Shrine
-- Source: sources/projecteq/skyshrine/A_Guardian_of_the_Shrine.pl
-- Source SHA256: 6b783a014b3967ef1e1d4835185a6a3cadfc2f94a02f957c72b33fc87698dd0f
-- P99 conversion review: changes/p99-conversion-world/closure-review.json
-- Complete local signal receiver only. Cross-zone Sleeper awakening remains
-- blocked separately; this translation does not establish its global delivery.
function event_signal(e)
  if e.signal == 66 then
    e.self:Shout("BEWARE! BEWARE! The Sleeper has been awakened! He means death for all who remain here! Time is short, flee the Skyshrine now if you value your life!")
  end
end
