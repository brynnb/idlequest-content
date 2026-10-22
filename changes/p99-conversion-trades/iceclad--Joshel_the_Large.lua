-- Converted from sources/projecteq/iceclad/Joshel_the_Large.pl
-- Original Perl SHA256: 45476e83a8d662a34ad666c00b83c06191d3c532d2056698dc9857122aa51a28
-- Review: changes/p99-conversion-trades/closure-review.json
-- Partial: documented P99 hail only; no verified P99 authority for bandana 60333.
-- The later/unverified Icebreaker reward branch is not activated or replaced with a guessed reward.

function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("That's right. Large, cause that's what I be. If'n ya don't like it, or even if ya do, ya best get to the dock on the other side o' this island. Ya never know when Icebreaker is gonna stop by again and ye not wantin' ta miss it.")
    end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
