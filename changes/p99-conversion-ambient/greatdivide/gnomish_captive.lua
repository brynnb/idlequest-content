-- name: gnomish_captive
-- Keep IdleQuest owner-scoped proximity/depop semantics; no static spawn is added.
-- Distinct from bloody_gnome_captive (118026), the existing Bloodmaw map recipient.
-- P99 bounded conversion review: 2026-10-22; see closure-review.json.
-- Original ProjectEQ flavor retained unless specifically documented; not a live-playability claim.
function event_spawn(e)
    local x, y = e.self:GetX(), e.self:GetY()
    eq.set_proximity(x - 20, x + 20, y - 20, y + 20)
end

function event_enter(e)
    e.self:Say("Please, somebody help me. This bear won't let me leave.")
    e.self:Emote("tries to hide from Bloodmaw deeper in the cave.")
    eq.clear_proximity()
    eq.depop()
end
