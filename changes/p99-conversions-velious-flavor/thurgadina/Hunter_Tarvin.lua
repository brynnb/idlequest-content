-- Reviewed 2026-10-22: P99 NPC presence, ProjectEQ flavor provenance.
-- Source: sources/projecteq/thurgadina/Hunter_Tarvin.pl
-- No new faction, class, level or epic gates; no rewards invented.

function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Good day, stranger. I would love to sit and chat with you but I don't much like gabbing it up with total strangers. I have other things to think on, Good day.")
    end
    if e.message:findi("thing") then
        e.self:Say("Well, I am a hunter. I travel out over the wastes to the east and bring back hides and meat. The businesses pay me a bit of coin for what I bring back and I buy me a room at the inn for a little bit. Then I get low on cash and go back out into the wastes. Although lately I find myself out hunting more often than I stay in the city.")
    end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
