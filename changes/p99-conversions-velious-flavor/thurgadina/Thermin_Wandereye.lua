-- Reviewed 2026-10-22: P99 NPC presence, ProjectEQ flavor provenance.
-- Source: sources/projecteq/thurgadina/Thermin_Wandereye.pl
-- No new faction, class, level or epic gates; no rewards invented.

function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Oh. HI! Hey, you're an adventurer aren't you? Yeah I thought so from your worn clothes and weapons. Wow, is that a real bloodstain? Some day I'll be adventuring out there too, some day, they'll see...")
    end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
