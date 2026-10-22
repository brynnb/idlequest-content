-- P99 Captain Nalot rum chain: documented item exchange.
-- Faction checks intentionally bypassed. XP/cash/faction magnitudes are undocumented and not invented.
-- Dropped quest rewards granted directly; movement/collapse choreography is represented in emotes, not simulated.
local item_lib = require("items")

function event_trade(e)
  if item_lib.check_turn_in(e.trade, { item1 = 30058, item2 = 30060 }) then
    e.self:Emote("laughs at you and then takes the sap and bladder. He mixes the two together and then adds something from a small pourch he carries. With a quick sizzle he pours some on his boots and the crud melts away. 'See that? Didn't do anything but get rid of the crud. This stuff is great. It doesn't burn yer skin or valuables. Here ya go, you can have the rest.'")
    e.other:SummonItem(30061)
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
