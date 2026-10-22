-- actors: world
-- Reviewed 2026-10-22: P99 NPC presence, ProjectEQ flavor provenance.
-- Source: sources/projecteq/thurgadina/Guard_Clorn.pl
-- No new faction, class, level or epic gates; no rewards invented.

function event_signal(e)
    e.self:Emote("chuckles saying, 'Have fun Lieutenant, bring me back an ale while yer at it why don't ye!'")
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
