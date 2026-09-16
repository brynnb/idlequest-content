-- Source: hole/Jaeil_the_Wretched.pl
-- Ranger Epic 1.0: Jaeil the Wretched spawns Jaeil the Insane.
-- Converted from ProjectEQ Perl quest script.
-- items: 17860

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 17860}) then
		e.self:Emote("howls in anger as he sees his reflection.")
		-- Retain the original Perl's explicit attack against the hand-in player.
		eq.spawn2(39154, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()):AddToHateList(e.other, 1)
		eq.depop()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
