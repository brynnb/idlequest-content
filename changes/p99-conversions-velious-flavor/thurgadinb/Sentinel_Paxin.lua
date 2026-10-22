-- Reviewed 2026-10-22: P99 NPC presence, ProjectEQ flavor provenance.
-- Source: sources/projecteq/thurgadinb/Sentinel_Paxin.pl
-- No new faction, class, level or epic gates; no rewards invented.

function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Greetings offlander. I see you are exploring our beloved Keep. By order of the Dain all offlanders that have been friendly to our people are permitted to explore all parts of Icewell Keep save this door I guard. Enjoy your stay.")
    end
    if e.message:findi("door") then
        e.self:Say("Why this door behind me which I stand in front of course. You didn't by chance fall on the ice and hit your head I hope good " .. e.other:GetRaceName() .. ". By order of the Dain, none are permitted to see or go beyond this entrance.")
    end
    if e.message:findi("beyond this entrance") then
        e.self:Say("Why beyond this door lies the most wonderous. . . oh wait, I can't tell you that " .. e.other:GetRaceName() .. ". All I can tell you is that the door has also been magically sealed by our Grand Historian. Please move along now and enjoy the rest of the Keep.")
    end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
