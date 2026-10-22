-- Authored from P99 Muffin Quests; no retained upstream script exists.
-- Partial: documented cash/factions only; raw XP and runtime NPC availability unverified.
-- Deliberate IdleQuest faction bypass; removed starter dialogue not restored.
function event_trade(e)
  local item_lib = require("items")
  if item_lib.check_turn_in(e.trade, {item1 = 1839}) then
    e.self:Say("Ah, praise Karana! These muffins look good enough to eat, har har har! Here is your payment and you have my deepest gratitude. We have to stick together in these times of turmoil you know.")
    e.other:GiveCash(0, 0, 8, 0)
    e.other:Faction(291, 2, 0)
    e.other:Faction(223, -1, 0)
    e.other:Faction(219, 1, 0)
    e.other:Faction(229, 1, 0)
    e.other:Faction(262, 1, 0)
    -- XP unverified and omitted, not a P99 zero-XP assertion.
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
