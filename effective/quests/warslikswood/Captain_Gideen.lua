-- Converted from ProjectEQ Perl quest script.
-- Source: warslikswood/Captain_Gideen.pl
-- items: 12441

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("I hope you have come to assist in the defense of the gate. We have had numerous assaults by the goblins. No doubt it is due to those [goblin watchers].")
	elseif e.message:findi("goblin watchers") then
		e.self:Say("Goblin Watchers are rumored to be the communication link between goblin outposts and patrols. We have found Goblin Watcher Signal Torches on a few of them. You bring me back no less than three and I will reward you.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12441, item2 = 12441, item3 = 12441}) then
		e.self:Say("Good work, " .. e.other:GetName() .. ". You are on your way to becoming a respected ally of the Iksar Empire. Keep up the good work. Take this reward for a job well done.")
		e.other:Faction(441, 5, 0)
		e.other:Faction(440, 5, 0)
		e.other:Faction(445, 5, 0)
		e.other:Faction(442, 5, 0)
		e.other:Faction(444, 5, 0)
		e.other:SummonItem(12357) -- Aloe Swatch
		e.other:GiveCash(0, 7, 0, 0)
		e.other:AddEXP(10)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
