-- name: Disciple_Atharm
-- Source: sources/projecteq/wakening/Disciple_Atharm.pl
-- Source SHA256: 0125444386bc26626d48de0e7e7f2633db8bd26bcd57dc9c6f5c7ba835225306
-- P99 conversion review: changes/p99-conversion-world/closure-review.json
-- Preserve source timed walk and authored one-way grid; no invented path.
-- Dolvad onset/onset2 inconsistency is corrected to the timer actually scheduled.
-- Perl timers use seconds; Lua timers use milliseconds. Movement heading-2 is retained.
function event_spawn(e)
  eq.set_timer("onset3", 90000)
end
function event_timer(e)
  if e.timer ~= "onset3" then return end
  e.self:MoveTo(-4357, -715, -183, -2, true)
  eq.stop_timer("onset3")
end
function event_signal(e)
  if e.signal == 1 then eq.start(26) end
end
