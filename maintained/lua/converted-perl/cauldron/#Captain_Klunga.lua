-- Converted from ProjectEQ Perl quest script.
-- Source: cauldron/#Captain_Klunga.pl
-- items: 12274, 12278

function event_spawn(e)
	e.self:SetAppearance(1)
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12278}) then
		e.self:SetAppearance(0)
		-- The Perl script walks Klunga to this spot and creates the chalice on
		-- waypoint arrival. IdleQuest does not currently expose NPC pathing in
		-- Lua captures, so create the quest object directly at the destination.
		eq.create_ground_object(12274, -395.87, 807.04, 68, 0)
		eq.set_proximity(-405.87, -385.87, 797.04, 817.04, 61.78, 81.78)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

