-- Converted from ProjectEQ Perl quest script.
-- Source: cabwest/Keeper_Bile.pl
-- P99 audit: Necro Spells
-- items: 12739, 12739, 12659, 12426

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings. I am Bile, Keeper of the Apprentice Ranks. My knowledge is that of the first circle of necromancy. I was once a great necromancer, but now I have a greater calling to protect the words of Kotiz. I also conduct many tests to ensure the spells are deciphered correctly. I am in need of an apprentice to [collect components].")
	elseif e.message:findi("collect components") or e.message:findi("interested") then
		e.self:Say("Hmm. Yes. I will need the following; One large scorpion pincer, one sabertooth cub canine and two brittle skulls. Bring these to me and I shall pay you and if I have an overscribed spell, I shall give you that also.")
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
