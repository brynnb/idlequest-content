-- Reviewed 2026-10-22: P99 NPC presence, ProjectEQ flavor provenance.
-- Source: sources/projecteq/thurgadina/Durfa.pl
-- No new faction, class, level or epic gates; no rewards invented.

function event_signal(e)
    e.self:Emote("pinches Doriggan")
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
