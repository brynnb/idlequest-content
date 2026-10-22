-- Reviewed 2026-10-22: P99 NPC presence, ProjectEQ flavor provenance.
-- Source: sources/projecteq/thurgadina/Clifus.pl
-- No new faction, class, level or epic gates; no rewards invented.

function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Hey, what do ye think yer lookin' at, ugly? Yeah, that's right. I called ye ugly. You gonna make somethin of it, " .. e.other:GetRaceName() .. "? Yeah, I didn't think ye would. The last guy that looked at me wrong took me fist right in his mouth, laid him out flat on the ground! He been drinkin' an' all but he woulda been laid out flat even if he hadna been.")
    end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
