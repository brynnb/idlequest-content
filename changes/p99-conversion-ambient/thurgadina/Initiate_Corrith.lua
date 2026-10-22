-- name: Initiate_Corrith
-- timers: world
-- Runtime limitation: DoAnim is currently a no-op; the original requested animation is retained.
-- P99 bounded conversion review: 2026-10-22; see closure-review.json.
-- Original ProjectEQ flavor retained unless specifically documented; not a live-playability claim.
function event_spawn(e)
    eq.set_timer("2", 30000)
end

function event_timer(e)
    e.self:DoAnim(2)
end
