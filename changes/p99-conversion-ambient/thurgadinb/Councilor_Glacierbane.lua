-- name: Councilor_Glacierbane
-- actors: world
-- P99 bounded conversion review: 2026-10-22; see closure-review.json.
-- Original ProjectEQ flavor retained unless specifically documented; not a live-playability claim.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("The giants aren't our only problem ya know? Them Rygorr Orcs in the wastes are up ta no good as well. But I wouldn't worry too much about them if'n I were you. Me own son Garadain is out there takin care of them. I almost feel sorry for those orcs hehe.")
    end
end

function event_signal(e)
    if e.signal == 1 then
        e.self:MoveTo(67,654,39,510,true)
    elseif e.signal == 2 then
        e.self:MoveTo(5,545,66,0,true)
    end
end
