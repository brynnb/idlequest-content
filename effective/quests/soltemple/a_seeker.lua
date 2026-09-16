-- Cleric Epic 1.0: a seeker accepts Coral Statue of Tarew and spawns a plasmatic priest.
-- items: 28051

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 28051}) then
		e.self:Emote("shakes violently as his hand closes on the coral statue. The statue begins to emit a reddish glow then shatters in a burst of fire and smoke.")
		eq.spawn2(80042, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()) -- a_plasmatic_priest
		eq.depop_with_timer()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
