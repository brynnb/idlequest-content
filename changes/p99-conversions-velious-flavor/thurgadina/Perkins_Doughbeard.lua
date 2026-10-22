-- Reviewed 2026-10-22: P99 NPC presence, ProjectEQ flavor provenance.
-- Source: sources/projecteq/thurgadina/Perkins_Doughbeard.pl
-- No new faction, class, level or epic gates; no rewards invented.

function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("As far as I'm concerned there are only two arts in this world: alcohol and food. The Velium Keg is probably the best place to go for the former but I've got all yer needs for the latter covered right here.")
    end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
