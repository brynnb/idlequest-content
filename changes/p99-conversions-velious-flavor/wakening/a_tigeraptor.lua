-- Reviewed 2026-10-22: P99 NPC presence, ProjectEQ flavor provenance.
-- Source: sources/projecteq/wakening/a_tigeraptor.pl
-- No new faction, class, level or epic gates; no rewards invented.

function event_combat(e)
    if e.joined then
        e.self:Emote("pounces on " .. e.other:GetName() .. " in a flurry of deadly claws and teeth.")
    end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
