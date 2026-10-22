-- Converted from sources/projecteq/thurgadina/Fergus_Sawdust.pl
-- Original Perl SHA256: 0a12189d421dc1c829045d7012c6e22fe3eae4c54bf5592bcd55bb270b18ce99
-- Review: changes/p99-conversion-trades/closure-review.json
-- Full bounded source conversion: hail and return-only trade.
-- P99 forum t=301249 reports this exact hail working; no guessed follow-up quests.

function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Can I help you with something? If you want anything to do with carpentry, somethin' I grew up with and was raised on, I can't help ya. Nope.")
    end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
