-- Source: kaesora/spectral_librarian.pl
-- Enchanter Epic 1.0: spectral librarian Enchanted Diamond.
-- Converted from ProjectEQ Perl quest script.
-- items: 10631, 10618

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10631}) then
		e.self:Say("You have no idea what it is like to be trapped in this place.")
		e.other:SummonItem(10618) -- Enchanted Diamond
		-- Preserve the original Perl's concrete spawned actor and numeric hate.
		eq.spawn2(88087, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), 0):AddToHateList(e.other, 1)
		eq.depop_with_timer()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
