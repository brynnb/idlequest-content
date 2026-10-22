-- enabled: false
-- P99 source-only scope exclusion: later_berserker_only. Historical callback body preserved byte-for-byte below.
-- IdleQuest starting guild note turn-in.
-- Source: kaladimb/Dravel_Axethrasher.pl
-- items: 36000, 36006

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 36000}) then
		e.self:Say("Tis a good thing ye're doing by joining up with us, $name. As a member, ye get a wee gift. Take this tunic. Now, take that rage that rushes through yer veins and go kill some of the vermin around the city!")
		e.other:SummonItem(36006)
		e.other:AddEXP(100)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
