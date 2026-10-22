-- enabled: false
-- P99 source-only scope exclusion: later_berserker_only. Historical callback body preserved byte-for-byte below.
-- IdleQuest starting guild note turn-in.
-- Source: oggok/Baddi_Waca.pl
-- items: 36001, 36007

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 36001}) then
		e.self:Say("Gud! Gud! Me gots some clothes for you. Now that yous a Bonecutter, yous need to start choppins things.")
		e.other:SummonItem(36007)
		e.other:AddEXP(100)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
