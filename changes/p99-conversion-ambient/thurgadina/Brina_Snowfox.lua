-- name: Brina_Snowfox
-- Repair: duplicate hardcoded Wood Elf / corrupt %#1472 greetings collapse to one player-race greeting.
-- Common prose is ProjectEQ, not independently verified P99 dialogue; race substitution is a documented template repair.
-- P99 bounded conversion review: 2026-10-22; see closure-review.json.
-- Original ProjectEQ flavor retained unless specifically documented; not a live-playability claim.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("There doesn't seem to be much call for a sketch artist in Thurgadin these days. what with all the sculptures and such. but I get by. Care to purchase one of my sketches. " .. e.other:GetRaceName() .. "?")
    end
end
