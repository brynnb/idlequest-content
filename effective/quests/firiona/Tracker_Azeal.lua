-- Converted from ProjectEQ Perl quest script.
-- Source: firiona/Tracker_Azeal.pl

function event_spawn(e)
	eq.set_timer("ZoneTime", 30000)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("looks over at you and gives you an awkward smile, then quickly looks away. You notice he isn't like most of the elves you've seen. You can't quite put your finger on it, but for one thing he smells like he hasn't bathed in weeks.")
	end
end

function event_timer(e)
	local zone_time = eq.get_zone_time()
	if e.timer == "ZoneTime" and zone_time.zone_hour == 21 then
		eq.unique_spawn(84028, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()) -- Tracker_Azeal_
		eq.stop_timer("ZoneTime")
		eq.depop()
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
