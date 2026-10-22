-- name: Berzerker_Dolvad
-- Source: sources/projecteq/wakening/Berzerker_Dolvad.pl
-- Source SHA256: f732488891edc8003baebab8a5141791c25b5f8785e1bfdf3d4032fc0c50b2e5
-- P99 conversion review: changes/p99-conversion-world/closure-review.json
-- Preserve source timed walk and authored one-way grid; no invented path.
-- Dolvad onset/onset2 inconsistency is corrected to the timer actually scheduled.
-- Perl timers use seconds; Lua timers use milliseconds. Movement heading-2 is retained.
function event_spawn(e)
  eq.set_timer("onset2", 55000)
end
function event_timer(e)
  if e.timer ~= "onset2" then return end
  e.self:MoveTo(-4310, -741, -183, -2, true)
  eq.stop_timer("onset2")
end
function event_signal(e)
  if e.signal == 1 then eq.start(25) end
end
