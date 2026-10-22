-- Authored from P99 Muffin Quests; no retained upstream script exists.
-- Partial: documented cash/factions only; raw XP and runtime NPC availability unverified.
-- Deliberate IdleQuest faction bypass; removed starter dialogue not restored.
function event_trade(e)
  local item_lib = require("items")
  if item_lib.check_turn_in(e.trade, {item1 = 1839}) then
    e.self:Say("These are quality muffins! You are obviously quite a skilled baker. Here is your payment as promised. Now I can get back to business again.")
    e.other:GiveCash(0, 0, 6, 0)
    e.other:Faction(229, 2, 0)
    e.other:Faction(281, 2, 0)
    e.other:Faction(291, 1, 0)
    e.other:Faction(336, 2, 0)
    -- XP unverified and omitted, not a P99 zero-XP assertion.
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
