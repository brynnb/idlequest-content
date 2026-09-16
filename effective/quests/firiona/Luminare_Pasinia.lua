-- Converted from ProjectEQ Perl quest script.
-- Source: firiona/Luminare_Pasinia.pl
-- items: 12948, 12834, 12743, 12824, 12949

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("wave's her hand's as if to cast a spell.")
		e.self:Say("Greeting's!! I am the Luminare of Firiona. By decree of his royal highness, King Thex, I am here to research spell's and artifact's. I have much to do. I welcome any enchanter who offer's to [assist] the great Luminare.")
	elseif e.message:findi("assist") then
		e.self:Say("And great I am, indeed!! Alas, not great enough to be everywhere at once. I would gladly reward you if you would [collect] components for me.")
	elseif e.message:findi("collect") then
		e.self:Say("Then go into the wilds beyond the outpost and upon your return, you shall give me one Nok Shaman Powder, one Heart of Ice, one Ton Warrior Totem, and one Sabertooth Tiger Mane. This shall earn you knowledge of an enchanter spell I recently scribed.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12948, item2 = 12834, item3 = 12743, item4 = 12824}) then
		e.self:Emote("place's the items into a sack and removes a scroll from her robe.")
		e.self:Say("This is yours. A spell I discovered and translated for one with less intelligence than the great Luminare of Firiona Vie. You may kiss my feet now.")
		e.other:Faction(248, 10, 0)
		e.other:Faction(326, 10, 0)
		e.other:Faction(312, 10, 0)
		e.other:Faction(441, -10, 0)
		e.other:Faction(313, -10, 0)
		e.other:AddEXP(250)
		e.other:SummonItem(12949)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
