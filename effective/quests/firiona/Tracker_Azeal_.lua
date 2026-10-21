-- Converted from ProjectEQ Perl quest script.
-- Source: firiona/Tracker_Azeal_.pl
-- items: 12691

function event_spawn(e)
	e.self:Say("I'm going to start my patrol. I'll report back by morning.")
	eq.set_timer("Patrol", 10000)
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12691}) then
		e.self:Emote("begins to pull his face off.. it is a disguise!! 'Aha!! You have made it!! I cannot see well in this disguise, but I thought I smelled you. I have [news of the Charasis tome].'")
		e.other:Ding()
		eq.unique_spawn(84319, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
		eq.unique_spawn(84311, 0, 0, -1822, 617, 142.5, 206)
		eq.depop()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_timer(e)
	if e.timer == "Patrol" then
		-- The Perl source starts grid 11 here; the conversion dropped it.
		eq.start(11)
		eq.stop_timer("Patrol")
		eq.set_timer("ZoneTime", 60000)
	elseif e.timer == "ZoneTime" and eq.get_zone_time().zone_hour == 6 then
		eq.unique_spawn(84277, 0, 0, 2268, -2828, -74.8, 475)
		eq.stop_timer("ZoneTime")
		eq.depop()
	end
end
