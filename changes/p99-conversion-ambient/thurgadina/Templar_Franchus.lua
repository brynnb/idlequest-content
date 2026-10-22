-- name: Templar_Franchus
-- timers: world
-- P99 bounded conversion review: 2026-10-22; see closure-review.json.
-- Original ProjectEQ flavor retained unless specifically documented; not a live-playability claim.
function event_spawn(e)
    eq.set_timer("1", 480000)
end

function event_timer(e)
    e.self:Say("Ok lads, remember what I taught you now. Thrust, block, slash...")
end
