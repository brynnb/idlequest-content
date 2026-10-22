-- name: Councilor_Dirkins
-- actors: world
-- P99 bounded conversion review: 2026-10-22; see closure-review.json.
-- Original ProjectEQ flavor retained unless specifically documented; not a live-playability claim.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("I'm sure if you've listened to my fellow councilors babble on for awhile you must surely think our nation is in chaos. Thats far from the truth however as we do not make the decisions for our people. It is the Dain's will alone that decides what course our people take, we simply offer our advice and opinions. Dain Frostreaver IV is a good and wise man, trust in him will take our people far I promise you.")
    end
end

function event_signal(e)
    if e.signal == 1 then
        e.self:MoveTo(-103,703,39,264,true)
    elseif e.signal == 2 then
        e.self:MoveTo(0,535,68,0,true)
    end
end
