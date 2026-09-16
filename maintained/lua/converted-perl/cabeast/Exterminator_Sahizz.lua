-- Converted from ProjectEQ Perl quest script.
-- Source: cabeast/Exterminator_Sahizz.pl
-- items: 12466

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings, " .. e.other:GetName() .. ". Help rid this area of vermin! Bring me four loose scales for a few coin and good favor in town.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12466, item2 = 12466, item3 = 12466, item4 = 12466}) then
		e.self:Say("Thank you, " .. e.other:GetName() .. ". Here is your reward.")
		e.other:AddEXP(50)
		e.other:GiveCash(0, 5, 0, 0)
		e.other:Faction(440, 3, 0) -- Cabilis Residents
		e.other:Faction(441, 3, 0) -- Legion of Cabilis
		e.other:Faction(442, 3, 0) -- Crusaders of Greenmist
		e.other:Faction(444, 3, 0) -- Swift Tails
		e.other:Faction(445, 3, 0) -- Scaled Mystics
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
