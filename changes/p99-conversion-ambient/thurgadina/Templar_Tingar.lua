-- name: Templar_Tingar
-- timers: world
-- P99 bounded conversion review: 2026-10-22; see closure-review.json.
-- Original ProjectEQ flavor retained unless specifically documented; not a live-playability claim.
function event_spawn(e)
    eq.set_timer("1", 480000)
    eq.set_timer("2", 840000)
end

function event_timer(e)
    if e.timer == "1" then
        e.self:Say("Oh Brell, what ever did I do to inspire your wrath?")
    elseif e.timer == "2" then
        e.self:Say("Ok, let's try this again.")
        e.self:Say("ROYGHT FACE!")
    end
end
