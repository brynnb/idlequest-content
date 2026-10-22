-- name: Julius_Oresko
-- NPC availability on P99 is unverified; exact exported key retained, no NPC row added.
-- P99 bounded conversion review: 2026-10-22; see closure-review.json.
-- Original ProjectEQ flavor retained unless specifically documented; not a live-playability claim.
function event_aggro(e)
    e.self:Say("My blades have slain dragons! A " .. e.other:GetRaceName() .. " like you does not have a chance of survival!")
end
