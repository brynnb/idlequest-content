-- name: Councilor_Amberfeld
-- actors: world
-- P99 bounded conversion review: 2026-10-22; see closure-review.json.
-- Original ProjectEQ flavor retained unless specifically documented; not a live-playability claim.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Hail there, " .. e.other:GetCleanName() .. ". Amberfeld's the name and minin' is my trade. As the council representative of the Snowchippers, it be my duty ta make sure all these politicians and warmongers don't forget one thing. And that's that it's us miners that bring in the ore for weapons and the stones for their fancy houses.")
    end
end

function event_signal(e)
    if e.signal == 1 then
        e.self:MoveTo(108,665,38,126,true)
    elseif e.signal == 2 then
        e.self:MoveTo(25,542,65,0,true)
    end
end
