-- Source: paineel/Duriek_Bloodpool.pl
-- Shadow Knight Epic 1.0: Duriek Bloodpool Corrupted Ghoulbane chain.
-- Converted from ProjectEQ Perl quest script.
-- items: 18099, 14365, 14382, 5403, 11609, 5430, 14366, 14367
-- P99 dialogue directions restored from the July 17, 2026 cached epic page.
-- Condensed wording must retain the next objective, not just the greeting.

function event_say(e)
	local faction = e.other:GetCharacterFactionLevel(404) -- True Spirit
	if e.message:findi("apprentice") and faction >= 14 then
		e.self:Say("As stubborn and foolish as he sometimes was, he was full of potential. I must now get to the task of replacing my associate.")
	elseif e.message:findi("replace him") and faction >= 14 then
		e.self:Say("Bring me back a bottle of cough elixir and, if you are still interested, I will instruct you further.")
	elseif e.message:findi("searching") and faction >= 21 then
		e.self:Say("I have a key to open a sealed tome hidden in the recently uncovered ruins. Bring that tome back to me so I can finish researching how to corrupt the Ghoulbane.")
	elseif e.message:findi("items") and faction >= 28 then
		e.self:Say("I will need the Ghoulbane, the Soul Leech, the Blade of Abrogation, and the Decrepit Sheath.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	local faction = e.other:GetCharacterFactionLevel(404) -- True Spirit
	if faction >= 7 and item_lib.check_turn_in(e.trade, {item1 = 18099}) then
		e.self:Say("This is unfortunate news about my apprentice. I had already paid the Neriak rogues to settle his gambling debt, but he would not heed my warnings. I must find someone to replace him.")
		e.other:Faction(404, 7)
		e.other:AddEXP(15000)
	elseif faction >= 14 and item_lib.check_turn_in(e.trade, {item1 = 14365}) then
		e.self:Say("Thank you. My time is short. I have nearly finished researching a corrupted Ghoulbane, but my apprentice died while searching for the final clue. You must continue his search.")
		e.other:Faction(404, 7)
	elseif faction >= 21 and item_lib.check_turn_in(e.trade, {item1 = 14382}) then
		e.self:Emote("opens the tome with his key and reads eagerly. At last, he has found the items required to corrupt the Ghoulbane.")
		e.other:Faction(404, 7)
	elseif faction >= 35 and item_lib.check_turn_in(e.trade, {item1 = 5403, item2 = 11609, item3 = 5430, item4 = 14366}) then
		e.self:Emote("takes the Ghoulbane and places the other swords on either side of it. With his last bit of energy, Duriek places the corrupted Ghoulbane in your hands.")
		e.self:Say("The tome revealed more than the creation of this blade. To continue, seek the powerful lich named Lhranc. Farewell.")
		e.other:Faction(404, 7)
		e.other:SummonItem(14367) -- Corrupted Ghoulbane
		e.self:SetAppearance(3)
		eq.set_timer("depop", 5000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_timer(e)
	eq.depop_with_timer()
end
