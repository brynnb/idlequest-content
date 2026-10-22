-- name: Councilor_Icepike
-- actors: world
-- P99 bounded conversion review: 2026-10-22; see closure-review.json.
-- Original ProjectEQ flavor retained unless specifically documented; not a live-playability claim.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("King Tormax must be stopped, no matter what the cost.")
    end
end

function event_signal(e)
    if e.signal == 1 then
        e.self:MoveTo(117,701,39,256,true)
    elseif e.signal == 2 then
        e.self:MoveTo(30,533,68,0,true)
    end
end
