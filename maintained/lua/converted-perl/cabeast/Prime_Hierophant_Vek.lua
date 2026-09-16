-- IdleQuest starting guild note turn-in.
-- Source: cabeast/Prime_Hierophant_Vek.pl
-- items: 18206, 5140

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18206}) then
		e.self:Say("Welcome, young petitioner. You have been summoned to this temple to join with the Scaled Mystics. Ours is the way of pain and suffering. Here is the weapon of a petitioner. Through you the power of our ancestors shall flow. As your wisdom grows, so shall your power. Someday you may be a vessel for the supreme might of the ancients. Seek knowledge with Oxyn, he is here to help you.")
		e.other:SummonItem(5140)
		e.other:AddEXP(500)
		e.other:Faction(445, 100, 0)
		e.other:Faction(441, 25, 0)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
