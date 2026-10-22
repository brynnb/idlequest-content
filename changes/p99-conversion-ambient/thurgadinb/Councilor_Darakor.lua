-- name: Councilor_Darakor
-- actors: world
-- P99 bounded conversion review: 2026-10-22; see closure-review.json.
-- Original ProjectEQ flavor retained unless specifically documented; not a live-playability claim.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Hmmph, if you've come here to actually get something accomplished yer wastin yer time. This lot'll babble on endlessly about politics and luxuries. Only the Dain and a few others like myself want to deal with the actual problems of the Coldain, that being the bloody Kromrif of course.")
    end
end

function event_signal(e)
    if e.signal == 1 then
        e.self:MoveTo(-79,656,39,0,true)
    elseif e.signal == 2 then
        e.self:MoveTo(-15,544,66,0,true)
    end
end
