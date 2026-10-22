-- name: Councilor_Wintershade
-- actors: world
-- P99 bounded conversion review: 2026-10-22; see closure-review.json.
-- Original ProjectEQ flavor retained unless specifically documented; not a live-playability claim.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Councilor Darakor here would have you believe we should march every man, woman, and child in the city to Kael tommorow. He is a fool and so are those who support him. I for one would like to see greater steps in ending this senseless conflict. Oh sure the giants are unreasonable right now, but reason can be bought in time.")
    end
end

function event_signal(e)
    if e.signal == 1 then
        e.self:MoveTo(6,895,-2,256,true)
    elseif e.signal == 2 then
        e.self:MoveTo(-10,534,67,0,true)
    end
end
