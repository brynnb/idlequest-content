-- P99: https://wiki.project1999.com/Ridossan%27s_Spirit
-- Ported from upstream/projecteq/stonebrunt; existing faction convenience retained.
local item_lib = require("items")
function event_say(e)
  if e.message:findi("hail") then
    e.self:Emote("whispers of the Kejekan who slew him. He cannot take revenge in this [form].")
  elseif e.message:findi("form") or e.message:findi("revenge") then
    e.self:Emote("whispers that his lost weapon will let him become whole again. Return the Grimy Lance and help him take revenge.")
  end
end
function event_trade(e)
  if item_lib.check_turn_in(e.trade, {item1=2100}) then
    e.self:Say("Yes! The lance.")
    e.other:AddEXP(10000)
    e.other:SummonItem(2297)
    eq.set_timer("turn", 2000)
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
function event_timer(e)
  if e.timer == "turn" then
    eq.stop_timer("turn")
    eq.unique_spawn(100221, 323, 0, -70, 474, 509, e.self:GetHeading())
    eq.depop_with_timer()
  end
end
