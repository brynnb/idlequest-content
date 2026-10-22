-- enabled: false
-- P99 source-only scope exclusion: later_newcomer_armor_only. Historical callback body preserved byte-for-byte below.
-- Converted from ProjectEQ Perl quest script.
-- Source: neriakb/Andara_C-Luzz.pl
-- items: 19582, 19583, 16166, 19611

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 19582, item2 = 19583, item3 = 16166}) then
		e.other:SummonItem(19611)
		e.self:Say("Well done " .. e.other:GetName() .. "!  Use this with pride.")
		e.other:AddEXP(1000)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
