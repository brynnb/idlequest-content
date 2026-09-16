-- Converted from ProjectEQ Perl quest script.
-- Source: ecommons/Altunic_Jartin.pl
-- items: 18896, 13867, 1004, 13865

function event_waypoint_arrive(e)
	-- Original Perl toggled running at waypoints 2 and 3. Movement speed
	-- changes are non-reward behavior and are not represented in the Lua bridge.
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings, traveler! Have you need of provisions or perhaps other wares? I sell what I find upon the battlegrounds of the Commonlands.")
	elseif e.message:findi("Where is your house") then
		e.self:Say("Follow me.")
		-- Retain the original house destination; dialogue must not merely
		-- promise movement while spawning Narl remotely.
		e.self:MoveTo(4791.06, -83.55, -51.47)
		eq.spawn2(22196, 0, 0, 4707.63, -105.49, -51.47, 0)
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18896}) then
		e.self:Say("You are the one they have sent? A squire?!! I hope you can help me. I gather items strewn upon the grounds of the Commonlands. I sell them at good prices. Lately, I have been terrorized by a human rogue named Narl. He will no doubt appear at my [house] soon. Bring his head to me.")
	elseif item_lib.check_turn_in(e.trade, {item1 = 13867}) then
		e.self:Say("You have performed a great service to me, but I fear others will attack me while I stroll the countryside. It would be very noble of you to fetch me a cloth shirt for protection from wicked creatures. It is not much, but it will help.")
		e.other:GiveCash(7, 0, 0, 0)
		e.other:Faction(330, -1, 0)
		e.other:Faction(311, 1, 0)
		e.other:Faction(281, 1, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 1004}) then
		e.self:Say("Thank you. You are very noble for a squire. I can see you becoming a very valuable asset to the Hall of Truth. Take this token. Tell Merko that you have [earned the Token of Generosity].")
		e.other:SummonItem(13865)
		e.other:Faction(330, -1, 0)
		e.other:Faction(311, 1, 0)
		e.other:Faction(281, 1, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
