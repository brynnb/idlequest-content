-- Source: cabeast/Half_Elf_Maiden.pl
-- Converted from ProjectEQ Perl quest script.
-- items: 54026, 18863

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 54026}) then -- Klok's Seal
		e.self:Say("Oh! thank you! I did not expect to hear of my family ever again. This seal should grant me protection out of the city if I am careful. Please take this note to my father and let him know I am safe!")
		e.other:SummonItem(18863) -- Sealed Letter
		e.other:AddEXP(2000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
