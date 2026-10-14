-- P99 Coldain Ring Quests #5; original a_coldain_lookout.pl is preserved.
-- P99 documents +10 Coldain/Dain, not upstream +30. Negative faction amounts
-- retain upstream where P99 is silent. The faction prerequisite stays bypassed.
local item_lib = require("items")
function event_trade(e)
  if item_lib.check_turn_in(e.trade, {item1 = 30136}) then
    e.self:Shout("Aahhh.. You're too late! They're upon us! To arms, men! Death to Scarbrow!")
    local coordinator = eq.spawn2(116570, 0, 0, -642, -2591, 190, 0)
    coordinator:Signal(1)
    e.other:Faction(406, 10)
    e.other:Faction(405, 10)
    e.other:Faction(419, -30)
    e.other:Faction(448, -30)
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
