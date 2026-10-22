-- IdleQuest starting guild note turn-in.
-- Source: cabeast/Grand_Master_Glox.pl
-- items: 18204, 4190

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18204}) then
		e.self:Emote("breaks his meditation and quickly grabs your forearms. You feel the raw power in his heavily callused hands. Out of nowhere, his tail sweeps forward and places a shackle upon your wrist. He then points south towards Master Bain and returns to his meditation.")
		e.other:SummonItem(4190)
		e.other:AddEXP(100)
		e.other:Faction(444, 200, 0)
		e.other:Faction(441, 50, 0)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 14788}) then
		e.self:Emote("scrawls instructions on the note and resumes meditation.")
		e.other:SummonItem(18980)
	elseif item_lib.check_turn_in(e.trade, {item1 = 14782, item2 = 10032, item3 = 10032}) then
		e.self:Emote("scratches a brief reference and motions for you to leave.")
		e.other:SummonItem(14783)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
