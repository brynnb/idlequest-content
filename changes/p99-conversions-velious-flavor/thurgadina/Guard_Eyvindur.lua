-- Reviewed 2026-10-22: P99 NPC presence, ProjectEQ flavor provenance.
-- Source: sources/projecteq/thurgadina/Guard_Eyvindur.pl
-- No new faction, class, level or epic gates; no rewards invented.

function event_say(e)
    if e.message:findi("Hail") then
        e.self:Say("Just because the Dain ordered us to let you offlanders into our city does not mean I have to speak with ye. Now move along.")
    end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
