-- Modified from ProjectEQ Lua to preserve Classic Lenka's Pouch clue dialogue
-- while omitting the later paladin epic branch that uses unavailable items.
-- Source: freporte/Brunar_Rankin.lua
-- P99: https://wiki.project1999.com/Lenka%27s_Pouch

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("How are you? Please excuse my stench. I fish all day and night just to feed my large family. You look like an adventurer. That must be exciting. I am but a humble fisherman. Maybe someday we shall both be rich. You by your treasure and me by my catch.")
	elseif e.message:findi("steal from lenka") then
		e.self:Say("How dare you accuse me of being a thief!? I labor hour after hour trying to catch one fish which will bring me one copper piece to buy one slice of bread which I will split into five pieces to feed me, my sick wife and three little children, one of whom has the plague!! Poor little Repi. Now please, leave this humble little fisherman alone!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_waypoint_arrive(e)
	if e.wp == 13 then
		e.self:Say("Here is my catch for today, Gregor")
		eq.signal(382135, 1) -- Gregor_Nasin
	elseif e.wp == 34 then
		e.self:Say("Ho hum, what a lovely day!")
		e.self:SetRunning(true)
	elseif e.wp == 39 then
		e.self:SetRunning(false)
	elseif e.wp == 44 then
		e.self:SetRunning(true)
	elseif e.wp == 59 then
		e.self:SetRunning(false)
	end
end
