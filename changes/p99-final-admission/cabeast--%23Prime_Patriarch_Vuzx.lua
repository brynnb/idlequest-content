-- enabled: false
-- P99 source-only scope exclusion: later_beastlord_only. Historical callback body preserved byte-for-byte below.
-- IdleQuest starting guild note turn-in.
-- Source: cabeast/#Prime_Patriarch_Vuzx.pl
-- items: 18848, 13577

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18848}) then
		e.self:Say("The Hierophants have sensed that your spirit is strong with obedience inspiring fear! You must learn to harness your powers over the scaled wolves! Wear this tunic so the Legion of Cabilis will recognize you as a Scaled Spiritist.")
		e.other:SummonItem(13577)
		e.other:AddEXP(100)
		e.other:Faction(445, 15, 0)
		e.other:Faction(441, 3, 0)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
