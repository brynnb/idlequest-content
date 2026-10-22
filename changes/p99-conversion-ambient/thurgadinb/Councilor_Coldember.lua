-- name: Councilor_Coldember
-- actors: world
-- P99 bounded conversion review: 2026-10-22; see closure-review.json.
-- Original ProjectEQ flavor retained unless specifically documented; not a live-playability claim.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Watch yer step around the Icewell there, " .. e.other:GetCleanName() .. ". I've heard that a giant beast lives down in the pit waiting to devour those who earn the punishment of being dropped down there. Might be just I rumor but I swear I've heard some sounds comin up from the well that don't resemble any of the creatures we put in there.")
    end
end

function event_signal(e)
    if e.signal == 1 then
        e.self:MoveTo(93,655,39,488,true)
    elseif e.signal == 2 then
        e.self:MoveTo(15,543,66,0,true)
    end
end
