-- P99 review: 2026-10-22; cached wiki evidence retained in review.json.
-- Quest faction requirements intentionally bypassed; no new level gate.
-- P99 confirms NPC/quest identity but no hail text; ProjectEQ flavor text retained.
-- Tiny Savages kill target: no invented hand-in, reward, or scripted death loot.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Hail and welcome to the Dain's trophy room. Not many people realize that aside from bein' a great warrior and king. Frostreaver is also one of our nation's greatest hunters. Here you can see some examples of his handiwork including orcs, a frost giant, a snow griffin, and even a rare albino manticore! You can find many such rare critters in the Eastern Wastes. Good luck and happy huntin'.")
    end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
