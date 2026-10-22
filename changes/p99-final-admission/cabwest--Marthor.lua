-- P99 scope: retain ordinary hail; remove later Tynnonium/Whistling Fists brew state and hand-ins.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Emote("hiccups and breathes drunken breath in your face saying, Leave me be, can't you see that I am meditating or something?")
    end
end
function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
