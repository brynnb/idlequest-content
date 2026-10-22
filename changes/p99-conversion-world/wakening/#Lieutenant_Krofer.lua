-- enabled: false
-- name: #Lieutenant_Krofer
-- Source: sources/projecteq/wakening/#Lieutenant_Krofer.pl
-- Source SHA256: daf04ad67f5476bf583561dda0acd1ccf200cf0c926c82df1aff75829b27bb66
-- P99 conversion review: changes/p99-conversion-world/closure-review.json
-- Separately authorized exact receiver extension119173. Preserve25-minute
-- lifetime, mission-report exchange,1000upstreamXP, and postreward depop.
-- Actual enabled=0 quest policy is retained, not bypassed by this conversion.
local item_lib = require("items")
function event_spawn(e) eq.set_timer("leave", 1500000) end
function event_trade(e)
  if item_lib.check_turn_in(e.trade, {item1 = 1708}) then
    e.self:Say("Failure! Incompetence! The whole squad anihilated! I knew this would happen if left in the hands of a worthless mercenary! Well, you can take this report back to Drioc then. Now get out of my sight, mercenary.")
    e.other:AddEXP(1000); e.other:Ding(); e.other:SummonItem(1709)
    eq.depop()
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
function event_timer(e)
  if e.timer ~= "leave" then return end
  eq.stop_timer("leave")
  eq.depop()
end
