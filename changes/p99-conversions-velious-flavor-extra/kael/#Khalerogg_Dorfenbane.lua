-- Reviewed 2026-10-22: P99 NPC presence, ProjectEQ flavor provenance.
-- Source: sources/projecteq/kael/#Khalerogg_Dorfenbane.pl
-- No new faction, class, level or epic gates; no rewards invented.

function event_aggro(e)
    e.self:Say("Your bones will be crushed by the Kromrif of Kael Drakkel!")
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
