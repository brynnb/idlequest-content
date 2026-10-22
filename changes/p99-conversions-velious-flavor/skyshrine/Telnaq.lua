-- Reviewed 2026-10-22: P99 NPC presence, ProjectEQ flavor provenance.
-- Source: sources/projecteq/skyshrine/Telnaq.pl
-- No new faction, class, level or epic gates; no rewards invented.

function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Hello, " .. e.other:GetRaceName() .. ", did you know Lord Yelinak has built a maze to protect the upper levels of the towers from invasion. Keep that in mind when traveling through the shrine.")
    end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
