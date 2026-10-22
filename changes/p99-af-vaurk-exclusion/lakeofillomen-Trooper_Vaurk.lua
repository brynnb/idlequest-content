-- Explorer Survival Knives is explicitly marked {{delete}}{{DNE}} on P99:
-- "Added in early Luclin". Do not activate its knife exchange or advertising.
-- All former dialogue concerned that excluded exchange. NPC spawn, combat,
-- faction, inventory and other world data remain unchanged.
function event_say(e)
end

function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
