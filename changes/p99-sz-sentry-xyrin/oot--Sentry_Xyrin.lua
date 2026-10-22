-- Modified from ProjectEQ Lua.
-- Source: oot/Sentry_Xyrin.lua
-- P99 audit: Sentry Xyrin Quest
-- items: 12134, 12135, 5414

local escort_stage = 0 -- persisted closure state; 0=waiting, 1=escort, 2=finished

function event_spawn(e)
	escort_stage = 0
	eq.set_timer("depop",3600000);
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Shhhh!! Keep quiet! Can you not tell this island is inhabited by undead? I wish to take the fight to them, but I am weak from the [boat disaster].");
	elseif(e.message:findi("boat disaster")) then
		e.self:Say("I was returning to my temple in Freeport in a small boat when the storm hit. I soon found myself shipwrecked on this evil island of undead. The words of Marr tell me to destroy these beings, but I am far too weak. If I only had a sip of the [Potion of Marr].");
	elseif(e.message:findi("potion of marr")) then
		e.self:Say("The Potion of Marr was created for the Sentries of Passion. It makes us alert and energetic. It will work only on sentries such as myself. It is distributed by Serna Tasknon of the Temple of Marr in Freeport.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(escort_stage == 0 and item_lib.check_turn_in(e.trade, {item1 = 12134})) then
		escort_stage = 1
		eq.stop_timer("depop");
		eq.set_timer("escort_complete",360000);
		e.self:Say("Ahhhh! I am energized! Come! Let us show these undead the greatness of Erollisi Marr!");
		e.other:SummonItem(12135); -- Empty Potion of Marr
		e.other:Ding();
		e.other:Faction(362,1,0); -- Priests of Marr
		e.other:Faction(330,-1,0); -- The Freeport Militia
		e.other:Faction(281,1,0); -- Knights of Truth
		eq.start(62);
		e.self:SetRunning(true);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_waypoint_arrive(e)
	if(e.wp == 4) then
		e.self:Shout("Long live Marr !!");

	end
end

function event_timer(e)
	if(e.timer == "escort_complete" and escort_stage == 1) then
		escort_stage = 2
		eq.stop_timer("escort_complete");
		eq.stop_timer("depop");
		e.self:Say("Many thanks to all who aided in this battle. I offer you this, a weapon I found on a slain Erudite paladin. May Marr watch over his soul and may Marr guide yours. Now I must go.");
		-- P99: after six minutes, drop at current position, regardless of aggro.
		-- Existing thirty-minute item decay retained; P99 does not document decay.
		eq.create_ground_object(5414,e.self:GetX(),e.self:GetY(),e.self:GetZ(),e.self:GetHeading(),1800000);
		eq.depop();
	elseif(e.timer == "depop" and escort_stage == 0) then
		eq.stop_timer("depop");
		eq.depop();
	end
end
