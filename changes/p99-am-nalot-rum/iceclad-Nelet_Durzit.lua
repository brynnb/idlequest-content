-- P99 Captain Nalot rum chain: documented item exchange.
-- Faction checks intentionally bypassed. XP/cash/faction magnitudes are undocumented and not invented.
-- Dropped quest rewards granted directly; movement/collapse choreography is represented in emotes, not simulated.
local item_lib = require("items")

function event_trade(e)
  if item_lib.check_turn_in(e.trade, { item1 = 30034 }) then
    e.self:Emote("greedily swigs rum from the jug. After a few drinks, he starts to gag and make faces. 'Oh geez! Rendap told me this stuff was strong, but this tastes like clockwork grease! It burns but now I feel - ugh.' Nelet doubles over and passes out on the ground. As he falls over, a small silver trinket slips out of his pocket.")
    e.other:SummonItem(30033)
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
