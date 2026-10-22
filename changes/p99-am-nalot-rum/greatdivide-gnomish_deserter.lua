-- P99 Captain Nalot rum chain: documented item exchange.
-- Faction checks intentionally bypassed. XP/cash/faction magnitudes are undocumented and not invented.
-- Dropped quest rewards granted directly; movement/collapse choreography is represented in emotes, not simulated.
local item_lib = require("items")

function event_trade(e)
  if item_lib.check_turn_in(e.trade, { item1 = 30061 }) then
    e.self:Emote("grins and pours the ooze on his hand and the box. You hear a burning sizzle and then the box thumps onto the ground. 'Ow! Ow! Take it! Hah. I never thought I would get rid of that piece of...'")
    e.other:SummonItem(30039)
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
