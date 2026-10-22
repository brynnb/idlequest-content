-- P99 scope: remove task154 (Black Eggs for Breakfast) solicitation and snake-egg consumer.
-- Keep only the existing ordinary greeting prefix; do not advertise a removed task.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Hello, " .. e.other:GetName() .. ".")
    end
end
function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
