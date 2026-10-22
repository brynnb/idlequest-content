-- name: Councilor_Thubins
-- actors: world
-- P99 bounded conversion review: 2026-10-22; see closure-review.json.
-- Original ProjectEQ flavor retained unless specifically documented; not a live-playability claim.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Come to see the excitement of the court have you friend? I'm just now working on my latest draft for a new waste disposal ordinance to present to the Dain, it's absolutely fascinating!")
    end
end

function event_signal(e)
    if e.signal == 1 then
        e.self:MoveTo(-53,703,39,258,true)
    elseif e.signal == 2 then
        e.self:MoveTo(-20,535,68,0,true)
    end
end
