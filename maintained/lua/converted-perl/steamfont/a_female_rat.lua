-- Converted from ProjectEQ Perl quest script.
-- Source: steamfont/a_female_rat.pl
-- items: 10262, 10263

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10262}) then
		e.self:Emote("ingests the virulent substance and becomes ill.")
		e.other:SummonItem(10263)
		e.other:AddEXP(100)
		eq.spawn2(56148, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
		eq.depop_with_timer()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
