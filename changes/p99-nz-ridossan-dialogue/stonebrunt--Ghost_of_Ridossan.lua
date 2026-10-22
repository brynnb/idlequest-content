-- P99: https://wiki.project1999.com/Ridossan%27s_Spirit
-- Ported from upstream/projecteq/stonebrunt; existing faction convenience retained.
local item_lib = require("items")
function event_spawn(e)
  -- P99 documents a roughly one-minute hand-in window.
  eq.set_timer("depop", 60000)
  e.self:Say("I will soon move on from this world to meet my ultimate fate. But before I go, I must reward the stranger that assisted me. Hand me the idol I gave you and you will be rewarded.")
end
function event_trade(e)
  if item_lib.check_turn_in(e.trade, {item1=2297}) then
    e.self:Emote("takes the idol into his spectral hand and shoves the lance into your arms. After letting go of the lance, the ghost immediately begins to fade away. Before it is gone completely, it looks into your eyes and says, 'Suffer.'")
    e.other:SummonItem(2099)
    eq.stop_timer("depop")
    eq.depop()
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
function event_timer(e)
  if e.timer == "depop" then eq.stop_timer("depop"); eq.depop() end
end
