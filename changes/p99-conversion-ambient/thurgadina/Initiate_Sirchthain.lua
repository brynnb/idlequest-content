-- name: Initiate_Sirchthain
-- timers: world
-- Runtime limitation: DoAnim is currently a no-op; original request retained.
-- Identity limitation: this original script key has no exact NPC name match; no alias or NPC row is invented.
-- P99 bounded conversion review: 2026-10-22; see closure-review.json.
-- Original ProjectEQ flavor retained unless specifically documented; not a live-playability claim.
local function reset_timer()
    -- Perl rand(40)+10 is [10,50) seconds, despite the inaccurate 10-40 comment.
    eq.set_timer("2", math.floor((math.random() * 40 + 10) * 1000))
end

function event_spawn(e)
    reset_timer()
end

function event_timer(e)
    e.self:DoAnim(2)
    reset_timer()
end
