-- enabled: false
-- P99 exclusion: see content_exclusions.json quests["tox/38139"].
-- Converted from ProjectEQ Perl quest script.
-- Source: tox/38139.pl
-- items: 13894, 10015, 10016, 10017, 10018

local jobresponse = 0
local numresponse = 0
local askresponse = 0
local beenonjob = 0
local eventstart = 0

function event_say(e)
	if e.message:findi("i am on the job") and askresponse == 1 and beenonjob == 1 then
		if e.other:HasItem(62829) then
			e.self:Say("Well I'll be, a druid that wants to be a miner! Alright then, you keep at it. Don't break a nail or strain your delicate sensibilities!")
			jobresponse = 1
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13894}) then
		e.self:Say("Good work, you should be running this operation instead of that Talrigar fellow. Have a small reward. A little bit of the gems I found while tunneling through this rock.")
		e.other:SummonItem(eq.ChooseRandom(10015, 10016, 10017, 10018))
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_waypoint_arrive(e)
	if e.wp == 5 then
		if eventstart == 0 then
			e.self:Say("Speed up the digging my pets!!")
			eq.signal(38016, 9)
		else
			e.self:Say("Who on Bertoxxulous' blistered backside are you? Where did those fools go off to?")
			eq.set_timer("1", 5000)
			jobresponse = 0
			askresponse = 1
		end
	end
end

function event_timer(e)
	if e.timer == "1" then
		eq.stop_timer("1")
		askresponse = 0
		if jobresponse == 1 then
			numresponse = numresponse + 1
			jobresponse = 0
		else
			numresponse = 0
		end
		if numresponse >= 3 then
			eq.signal(38016, 1)
			eventstart = 0
		end
	elseif e.timer == "2" then
		eventstart = 0
	elseif e.timer == "wallecho" then
		beenonjob = 0
	end
end

function event_signal(e)
	if e.signal == 1 then
		beenonjob = 1
		eq.set_timer("wallecho", 5000)
	elseif e.signal == 5 then
		jobresponse = 0
		beenonjob = 0
		numresponse = 0
		askresponse = 0
		eventstart = 1
		eq.set_timer("2", 1200000)
	end
end
