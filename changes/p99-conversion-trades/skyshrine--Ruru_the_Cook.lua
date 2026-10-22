-- Converted from sources/projecteq/skyshrine/Ruru_the_Cook.pl
-- Original Perl SHA256: 645a762431e7217354837deb89f86a354903f73467f619911fe3c71d826701cd
-- Review: changes/p99-conversion-trades/closure-review.json
-- Partial: standalone cooking hail and non-pie reaction signals 3/4/5; return-only trade.
-- Do not start Grudash's removed pie taunt from hail or continue the removed pie argument via signals 1/2.
-- No pie, other reward, faction change, XP, or quest progression is introduced.

function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Hey there stranger, pleased to meet you. I'm Ruru, I do the cooking around here. I'm the best cook around these parts. So, if you get hungry, you'd best be making sure you're coming to see me.")
    end
end

function event_signal(e)
    if e.signal == 3 then
        e.self:Say("Bah!")
    elseif e.signal == 4 then
        e.self:Emote("grumbles, 'Bah, this still doesn't settle anything Grudash. This stranger obviously has no taste for fine cuisine.'")
    elseif e.signal == 5 then
        e.self:Emote("laughs, 'Don't get me started. You know that my cuisine Is prefered over yours two to one.'")
    end
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
