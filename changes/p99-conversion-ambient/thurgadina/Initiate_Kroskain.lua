-- name: Initiate_Kroskain
-- timers: world
-- P99 bounded conversion review: 2026-10-22; see closure-review.json.
-- Original ProjectEQ flavor retained unless specifically documented; not a live-playability claim.
function event_spawn(e)
    eq.set_timer("1", 320000)
end

function event_timer(e)
    e.self:Say("Sir, you said Royt face. Guard Royt is just on the other side of this wall!")
end
