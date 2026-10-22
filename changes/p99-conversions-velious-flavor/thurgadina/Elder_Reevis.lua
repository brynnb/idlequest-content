-- Reviewed 2026-10-22: P99 NPC presence, ProjectEQ flavor provenance.
-- Source: sources/projecteq/thurgadina/Elder_Reevis.pl
-- No new faction, class, level or epic gates; no rewards invented.

function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("WHY, HELLO THAR, YOUNG LAD! GREAT DAY FER IT, AIN'T IT? YESSIREE! WHY THIS REMINDS ME O' THE DAYS BACK WHEN WE'D GATHER ROUND THE FIRE LIKE THIS AND.... OH. HELLO THAR, YOUNG LAD!  ER...  WHAT WAS I SAYIN'?")
    end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
