-- Converted from ProjectEQ Perl quest script.
-- Source: gfaydark/Idia.pl
-- items: 18166, 18167

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail. " .. e.other:GetName() .. " - Are you [interested] in helping the League of Antonican Bards by delivering some [mail]?")
	elseif e.message:findi("am interested") then
		e.self:Say("I have messages that need to go to - well. right now I have one that needs to go to Freeport.  Will you [deliver] mail to [Freeport] for me?")
	elseif e.message:findi("what mail") then
		e.self:Say("The League of Antonican Bards has a courier system made up of travelers, adventurers, and [agents].  We pay good gold to anyone who will take messages from bards such as myself to one of our more distant offices.  Are you [interested]?")
	elseif e.message:findi("agents") then
		e.self:Say("Lyra Lyrestringer, Tacar Tissleplay, Kilam Oresinger and Siltria Marwind all report to Jakum Webdancer.")
	elseif e.message:findi("deliver to freeport") then
		e.self:Say("Take this pouch of mail to Ton Twostring. You can find him at the bard guild hall. I'm sure he will compensate you for your trouble.")
		e.other:SummonItem(18166)
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18167}) then
		e.self:Say("More mail - you have done us a noteworthy service!  Please take this gold for your troubles.  If you are interested in more work, just ask me.")
		e.other:GiveCash(0, 0, eq.ChooseRandom(8, 9, 10, 11, 12), 0)
		e.other:AddEXP(1550)
		e.other:Faction(284, 5, 0)
		e.other:Faction(281, 1, 0)
		e.other:Faction(262, 1, 0)
		e.other:Faction(304, -1, 0)
		e.other:Faction(285, -1, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
