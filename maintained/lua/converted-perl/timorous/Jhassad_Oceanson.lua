-- Source: timorous/Jhassad_Oceanson.pl
-- Cleric Epic 1.0: Jhassad Oceanson merges the three orbs.
-- Converted from ProjectEQ Perl quest script.
-- items: 28048, 28049, 28050, 28023

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 28048, item2 = 28049, item3 = 28050}) then
		e.self:Emote("kneels in the sand and places the three orbs into a large abalone shell bowl. A blue glow surrounds his hands as he waves them over the orbs resting in the bowl.")
		e.self:Say("The Avatar of Water approaches. You must hand him the Orb of the Triumvirate and it will be decided if it is your destiny to wield the Nem Ankh Sprinkler.")
		e.other:SummonItem(28023) -- Orb of the Triumvirate
		eq.unique_spawn(96086, 21, 0, -1886, -11661, 1, 384) -- Avatar_of_Water
		eq.depop()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
