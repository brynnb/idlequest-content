-- name: #The_Sleeper
-- Source: sources/projecteq/sleeper/#The_Sleeper.pl
-- Source SHA256: 2f88272d98402dd802777c42ff57aab84c723adb8d919a024ac7db515cb097be
-- P99 conversion review: changes/p99-conversion-world/closure-review.json
-- Preserve the wake signal, exact actor/grid and appearance intent. SetAppearance
-- is currently cosmetic no-op; successor Kerafyrm cross-zone lifecycle is still blocked.
-- Do not claim the awakening family complete because this receiver is translated.
function event_spawn(e)
  eq.set_timer("sleep", 1000)
end
function event_timer(e)
  if e.timer ~= "sleep" then return end
  e.self:SetAppearance(1)
  eq.stop_timer("sleep")
end
function event_signal(e)
  if e.signal ~= 66 then return end
  e.self:Shout("I AM FREE!")
  eq.depop_with_timer()
  eq.spawn2(128089, 1, 0, -1499, -2344.8, -1052.8, 0)
end
