-- P99 Odd Items documents lore only; it does not establish a working hand-in.
-- Existing NPC 84141, spawn group 9630, spawn 14679 in Firiona Vie.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Glad to see you made it to the outpost in one piece. Now you can test your mettle against the giants of Kunark. They sometimes carry some [odd items] which can fetch a coin or two on the market.");
    elseif e.message:findi("odd items") then
        e.self:Say("I once spoke with a ranger who tried to sell me a mountain giant toothpick he recovered. Looked like it would make a fine weapon, but it smelled of decayed flesh!! I do not even care to think of what kind of flesh it was used to pick.");
    end
end

function event_trade(e)
    local item_lib = require("items");
    item_lib.return_items(e.self, e.other, e.trade);
end
