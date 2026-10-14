-- P99: https://wiki.project1999.com/Ridossan%27s_Spirit
-- Ported from upstream/projecteq/stonebrunt; existing faction convenience retained.
local item_lib = require("items")
function event_spawn(e)
  -- P99 documents a roughly one-minute hand-in window.
  eq.set_timer("depop", 60000)
  e.self:Say("Before I leave, hand me the token of Cazic-Thule, and I shall pass you the spear I once used.")
end
function event_trade(e)
  if item_lib.check_turn_in(e.trade, {item1=2297}) then
    e.self:Emote("takes the idol and shoves the lance into your arms. As he fades away, he whispers, 'Suffer.'")
    e.other:SummonItem(2099)
    eq.stop_timer("depop")
    eq.depop()
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
function event_timer(e)
  if e.timer == "depop" then eq.stop_timer("depop"); eq.depop() end
end
