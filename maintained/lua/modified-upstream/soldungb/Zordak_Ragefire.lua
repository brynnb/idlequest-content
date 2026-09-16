-- Source: soldungb/Zordak_Ragefire.lua

function event_spawn(e)
	-- Only the hostile transformation attacks; the Pearl recipient stays neutral.
	if e.self:GetNPCTypeID() == 91096 then
		eq.attack(e.other:GetName())
	end
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Emote("stares at you with unblinking eyes. A wide grin crosses Zordak's face and flames flicker in the depths of his eyes, 'Welcome to the new fortress of the Plasmatic Priesthood! It's a shame about Lord Nagafen's untimely death, really it is! Such a powerful and noble creature should not perish at the hands of mortals.'");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 28054})) then -- Shimmering Pearl
		e.self:Emote("is engulfed by a shimmering blue light! An inhuman expression of rage crosses his face and flames leap in his eyes as the Triumvirate's enchantment tears away his disguise. 'The Triumvirate may have forced my hand, but I shall return every drop of their mercy in flame!'");
		e.other:Ding();
		eq.spawn2(91096, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()); -- Zordak Ragefire, hostile human form
		eq.depop_with_timer();
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_death_complete(e)
	if(e.self:GetNPCTypeID() == 91096) then
		eq.spawn2(91090, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()); -- Zordakalicus Ragefire
	end
end

-- End of File, Zone:soldungb  NPC:32038/91096 -- Zordak_Ragefire
