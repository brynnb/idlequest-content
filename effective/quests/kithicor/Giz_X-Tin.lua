-- Source: kithicor/Giz_X-Tin.pl
-- Ranger Epic 1.0: Giz X-Tin turns Faelin's Ring into Dark Metal Coin.
-- Converted from ProjectEQ Perl quest script.
-- items: 20446, 20447

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20446}) then
		e.self:Emote("flips you a coin after he recognizes the ring.")
		e.other:SummonItem(20447) -- Dark Metal Coin
		-- Preserve the original Perl's concrete spawned actor and numeric hate.
		eq.spawn2(20190, 0, 0, e.self:GetX() + 20, e.self:GetY() + 20, e.self:GetZ(), e.self:GetHeading()):AddToHateList(e.other, 1)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
