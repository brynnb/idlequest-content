-- Source: timorous/Avatar_of_Water.pl
-- Cleric Epic 1.0: Avatar of Water grants Water Sprinkler of Nem Ankh.
-- Converted from ProjectEQ Perl quest script.
-- items: 28023, 5532

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 28023}) then
		e.self:Emote("takes the orb from you. The avatar has determined that you are worthy!")
		e.other:SummonItem(5532) -- Water Sprinkler of Nem Ankh
		e.other:AddEXP(200000)
		eq.depop()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
