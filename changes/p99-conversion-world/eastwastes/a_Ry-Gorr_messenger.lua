-- name: a_Ry-Gorr_messenger
-- Source: sources/projecteq/eastwastes/a_Ry-Gorr_messenger.pl
-- Source SHA256: 599dd580433a5716cb882ef9f3aaa7e94bcc1ff2372884a90a143827bd597a63
-- P99 conversion review: changes/p99-conversion-world/closure-review.json
-- Preserve departure19 plus60seconds and authored respawn. The shared patrol is
-- represented by the existing owner-scoped grid executor, not fabricated arrivals.
-- No loot or ring-five hand-in behavior is changed; grid233 is verified in data.
function event_spawn(e)
  -- Existing local placement 22501 uses this exact authored patrol.
  -- Start an owner-scoped cursor so normal authenticated waypoint events run.
  eq.start(233)
end
function event_waypoint_depart(e)
  if e.wp == 19 then eq.set_timer("leave", 60000) end
end
function event_timer(e)
  if e.timer ~= "leave" then return end
  eq.stop_timer("leave")
  eq.depop_with_timer()
end
