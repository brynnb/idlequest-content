-- P99 review: 2026-10-22; cached wiki evidence retained in review.json.
-- Quest faction requirements intentionally bypassed; no new level gate.
-- P99 Souvenir Mugs: one platinum buys the Broken Glacier mug (30146).
function event_say(e)
    if e.message:findi("hail") then
        e.self:Say("Hail and welcome to the Broken Glacier, " .. e.other:GetName() .. ". Ye'll find the bar downstairs and comfortable rooms up top. Can I interest you in one of our signature mugs? Only a platinum piece they are!")
    end
end

function event_trade(e)
    local item_lib = require("items")
    if item_lib.check_turn_in(e.trade, {platinum = 1}) then
        e.self:Say("Thank ye and enjoy it. All the bars here in Thurgadin have their own mugs, just ask the barkeep if'n yer interested.")
        e.other:SummonItem(30146)
    end
    item_lib.return_items(e.self, e.other, e.trade)
end
