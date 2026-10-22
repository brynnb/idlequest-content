-- name: Councilor_Darkfrost
-- actors: world
-- P99 bounded conversion review: 2026-10-22; see closure-review.json.
-- Original ProjectEQ flavor retained unless specifically documented; not a live-playability claim.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("It's that bastard Tormax whats the cause of all our trouble. What we need to do is send some specially trained assasins to take him out. Sure it's not the most honorable thing to do, but without him the giants wouldn't know what to do.")
    end
end

function event_signal(e)
    if e.signal == 1 then
        e.self:MoveTo(-4,887,-1,81,true)
    elseif e.signal == 2 then
        e.self:MoveTo(-5,543,66,0,true)
    end
end
