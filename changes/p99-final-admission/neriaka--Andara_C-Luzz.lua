-- enabled: false
-- P99 source-only scope exclusion: later_newcomer_armor_only. Historical callback body preserved byte-for-byte below.
-- Converted from ProjectEQ Perl quest script.
-- Source: neriaka/Andara_C-Luzz.pl
-- items: 16166, 19582, 19583, 19611

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 16166, item2 = 19582, item3 = 19583}) then
		e.other:AddEXP(150)
		e.other:SummonItem(19611)
		e.self:Say("Here's your bow. Use it well, young rogue.")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
