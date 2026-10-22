-- Reviewed 2026-10-22: P99 NPC presence, ProjectEQ flavor provenance.
-- Source: sources/projecteq/thurgadinb/Watcher_Devin.pl
-- No new faction, class, level or epic gates; no rewards invented.

function event_say(e)
    if e.message:findi("Hail") then
        e.self:Say("Greetings to you as well, " .. e.other:GetName() .. ". Down these stairs lies the hall of our ancestors. May Brell guide my axe swiftly to the necks of those who dare attempt to desecrate such a sacred place.")
    end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
