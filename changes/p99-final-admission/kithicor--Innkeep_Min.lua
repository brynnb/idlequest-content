-- P99 scope: retain ambient innkeeper hail; remove Halloween2018 state and scroll exchange.
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Greetings. " .. e.other:GetName() .. "!  Sure is strange seeing so many visitors lately out here in Kithicor. Good for business I guess!");
    end
end
function event_trade(e)
    local item_lib = require("items")
    item_lib.return_items(e.self, e.other, e.trade)
end
