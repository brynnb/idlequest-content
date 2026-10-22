-- Authored from P99 Muffin Quests; no retained upstream script exists.
-- Partial: documented cash/factions only; raw XP and runtime NPC availability unverified.
-- Deliberate IdleQuest faction bypass; removed starter dialogue not restored.
function event_trade(e)
  local item_lib = require("items")
  if item_lib.check_turn_in(e.trade, {item1 = 1839}) then
    e.self:Say("Ah yes! This is exactly what I am looking for, dear. Let me put these on the shelf right away. Here is some coin for your trouble. Perhaps we can do business again sometime.")
    e.other:GiveCash(0, 0, 6, 0)
    e.other:Faction(330, 1, 0)
    e.other:Faction(336, 1, 0)
    e.other:Faction(281, 1, 0)
    e.other:Faction(362, 1, 0)
    -- XP unverified and omitted, not a P99 zero-XP assertion.
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
