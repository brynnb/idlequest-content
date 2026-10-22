-- P99 Captain Nalot rum chain: documented item exchange.
-- Faction checks intentionally bypassed. XP/cash/faction magnitudes are undocumented and not invented.
-- Dropped quest rewards granted directly; movement/collapse choreography is represented in emotes, not simulated.
local item_lib = require("items")

function event_trade(e)
  if item_lib.check_turn_in(e.trade, { item1 = 30066, item2 = 30066, item3 = 30066, item4 = 30066 }) then
    e.self:Emote("jumps at you and snatches the meat from your hand. It runs away from you and feasts on the other side of the water. As it runs away you notice a small shiny object fall from its mouth.")
    e.other:SummonItem(30057)
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
