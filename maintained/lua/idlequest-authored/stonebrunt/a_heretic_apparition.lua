-- name: a_heretic_apparition
-- IdleQuest-authored cleanup; no corresponding upstream quest script exists.
-- P99 Spirit Aid: https://wiki.project1999.com/Spirit_Aid
-- Departure route/timing is undocumented. This local 60-second lifetime keeps
-- repeated hand-ins from accumulating permanent apparitions. No extra reward.
function event_spawn(e)
  eq.set_timer("depart", 60000)
end

function event_timer(e)
  if e.timer == "depart" then
    eq.stop_timer("depart")
    eq.depop()
  end
end
