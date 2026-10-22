-- P99 Souvenir Mugs, cached 2026-07-17; reviewed 2026-10-22.
-- P99 documents no hail reply. Five gold yields The Icy Mug Souvenir Stein.
-- New P99-authored source: no baseline Perl/Lua script exists for this NPC.
-- No faction or level gate; retain IdleQuest quest-only faction bypass.
function event_trade(e)
    local item_lib = require("items")
    if item_lib.check_turn_in(e.trade, {gold = 5}) then
        e.self:Say("Thank ye for yer Patronage. Enjoy yer mug and be sure ta visit us often.")
        e.other:SummonItem(30145)
    end
    item_lib.return_items(e.self, e.other, e.trade)
end
