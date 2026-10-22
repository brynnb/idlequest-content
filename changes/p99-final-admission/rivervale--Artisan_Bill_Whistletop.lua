-- P99 scope: remove source-explicit DoN cultural patterns and tasks500178-500181.
-- Preserve the existing ordinary non-halfling greeting exactly, including its message-independent trigger.
function event_say(e)
    if e.other:GetRaceName() ~= "Halfling" then
        e.self:Say(string.format("Hello %s!  Another fine day here in Rivervale!", e.other:GetCleanName()));
    end
end
function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
