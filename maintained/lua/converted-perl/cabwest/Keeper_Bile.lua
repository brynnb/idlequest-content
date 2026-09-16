-- Converted from ProjectEQ Perl quest script.
-- Source: cabwest/Keeper_Bile.pl
-- P99 audit: Necro Spells
-- items: 12739, 12739, 12659, 12426

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings " .. e.other:GetName() .. ". Lately the creatures of Lake of Ill Omen have be causing problems for us. Are you [interested] in helping me reduce the threat from this creatures?")
	elseif e.message:findi("interested") then
		e.self:Say("Good. Bring me two Brittle Iksar Skulls, a Sabertooth Cub Canine, and a Large Scorpion Pincer. And i shall reward you with a spell.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12739, item2 = 12739, item3 = 12659, item4 = 12426}) then
		e.self:Say("Good Work " .. e.other:GetName() .. ". This will surely hold back those vile creatures for some time. Here is your spell.")
		e.other:SummonItem(eq.ChooseRandom(15338, 15344, 15339, 15340, 15225, 15229, 15346, 15491, 15502, 15341, 15342, 15347, 15348, 15331, 15221, 15343))
		e.other:Faction(443, 5, 0) -- Brood of Kotiz
		e.other:Faction(441, 1, 0) -- Legion of Cabilis
		e.other:AddEXP(10)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
