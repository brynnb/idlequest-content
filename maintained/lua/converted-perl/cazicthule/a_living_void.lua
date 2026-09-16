-- Converted from ProjectEQ Perl quest script.
-- Source: cazicthule/a_living_void.pl
-- items: 8720

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 8720}) then
		eq.spawn2(48214, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

