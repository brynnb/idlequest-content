-- name: Councilor_Deynekn
-- actors: world
-- P99 bounded conversion review: 2026-10-22; see closure-review.json.
-- Original ProjectEQ flavor retained unless specifically documented; not a live-playability claim.
function event_signal(e)
    if e.signal == 1 then
        e.self:MoveTo(92,703,39,262,true)
    elseif e.signal == 2 then
        e.self:MoveTo(20,534,68,0,true)
    end
end
