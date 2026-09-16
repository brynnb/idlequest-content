-- Converted from ProjectEQ Perl quest script.
-- Source: kithicor/Grim_Oakfist.pl
-- items: 12341, 12342, 12343, 12367

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("It is good to finally meet one who respects the disciplines of the Ashen Order.  All I have met are rangers.  They have interfered with my [mission in the woods].")
	elseif e.message:findi("mission in the woods") then
		e.self:Say("I have come here to avenge my family.  One season past, they were attacked by a trio of deadly tigers.  I came here to hunt the beasts down, but then I found the local rangers and residents here protect the tigers.  They seem to be legends in these parts.  The tigers even have name's!!  They call them Eenot, Reggit and Kobb.  I wish I had help from a [fellow monk].")
	elseif e.message:findi("fellow monk") and e.other:GetFaction(e.self) < 5 then
		e.self:Say("Good!! The rangers are watching me so you must go alone.  I can only wait until the morning, then I must go.  If you find all three tigers, return their pelts to me and I shall reward you with something discovered for monks only.")
		eq.unique_spawn(20276, 0, 0, 4184, -745, 548, 0)
		eq.unique_spawn(20277, 0, 0, 1084, -707, 225, 0)
		eq.unique_spawn(20278, 139, 0, -608, 1007, -22, 0)
	elseif e.message:findi("treant fists") then
		e.self:Say("The treant fists were created by great craftsmen.  They are for the fists of a monk and offer greater dexterity and increase the durability of one's soul.  My last pair were given to Master Puab of the Ashen House training grounds.")
		eq.depop_with_timer()
	end
end

function event_trade(e)
	local item_lib = require("items")
	if e.other:GetFaction(e.self) < 5 and item_lib.check_turn_in(e.trade, {item1 = 12341, item2 = 12342, item3 = 12343}) then
		e.self:Say("Good work.  I hope you had no run ins with the local rangers.  Here is my reward.  An object from the past which I found in my journeys.  Wish that I could reward you also with [treant fists].")
		e.other:SummonItem(12367)
		e.other:AddEXP(100)
		e.other:Ding()
		e.other:Faction(361, 10, 0)
		e.other:Faction(281, 10, 0)
		e.other:Faction(309, 10, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
