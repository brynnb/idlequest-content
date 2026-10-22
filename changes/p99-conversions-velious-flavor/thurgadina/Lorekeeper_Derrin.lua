-- Reviewed 2026-10-22: P99 NPC presence, ProjectEQ flavor provenance.
-- Source: sources/projecteq/thurgadina/Lorekeeper_Derrin.pl
-- No new faction, class, level or epic gates; no rewards invented.

function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Greetings traveler. and welcome to the Temple of Lore. This library contains the sacred scrolls and texts of our ancestors, detailing both the history of their lives and the trials of our people. Previously the lore contained within these halls was forbidden to enter the hands of outsiders such as yourself. However, his majesty Dain Frostreaver IV has recently decreed that certain tomes of our heritage should be shared with the newly arrived offlanders so that they might better understand our culture. I have recently inscribed and translated several of these books which you may purchase for a modest donation.")
    end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
