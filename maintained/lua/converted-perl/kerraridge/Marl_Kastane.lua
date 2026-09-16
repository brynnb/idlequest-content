-- Source: kerraridge/Marl_Kastane.pl
-- Shadow Knight Epic 1.0: Marl Kastane ritual chain.
-- Converted from ProjectEQ Perl quest script.
-- items: 14375, 14376, 14381, 14377, 14379, 14370

function event_say(e)
	local faction = e.other:GetCharacterFactionLevel(404) -- True Spirit
	if e.message:findi("hail") then
		e.self:Say("Begone!! You do not have the will to do the things I require!")
	elseif e.message:findi("will of Innoruuk") then
		e.self:Say("You speak of a myth, friend. Such an object does not exist in this age and the secret of its creation lies locked in my mind, where it shall stay. It has been passed down through generations in my line, not to be revealed to a soul until the prophecy has come to pass.")
	elseif e.message:findi("prophecy") and faction >= 42 then
		-- With quest faction gates waived, keep both the delivery direction and
		-- the history available; do not use faction as a hidden progress counter.
		e.self:Say("Take this seal as proof that I sent you. Find my brother Gerot in Paineel and learn whether he is safe; our family's destiny depends on him.")
		e.self:Say("I suppose it is time for the secret to be shared. Ages ago, two brothers were born. Glohnor was highly favored by the pompous Lightbringer, whose name we do not utter. Lhranc was chosen by the Prince of Hate to bring destruction and turmoil to the sons of men.")
		e.other:SummonItem(14375) -- Seal of Kastane
	elseif e.message:findi("Lhranc") and faction >= 44 then
		e.self:Say("Lhranc wandered the deserts of Ro for weeks, sinking deeper into depression and giving in to rage.")
	elseif e.message:findi("one") and faction >= 44 then
		e.self:Say("Innoruuk had not forsaken Lhranc. He was given a weapon that made him powerful enough to slay any enemy that stood in his way.")
	elseif e.message:findi("curse") and faction >= 44 then
		e.self:Say("As I said, Glohnor was highly favored by the Lightbringer. When the contemptible god of honor discovered what had been done, he transformed Lhranc into a deformed spectral knight and placed him in the ruined city.")
	elseif e.message:findi("prediction") and faction >= 44 then
		e.self:Say("The prophecy states that one day Kyrenna will escape the clutches of Lhranc and that she will resurrect Glohnor.")
	elseif e.message:findi("secret plan") and faction >= 44 then
		e.self:Say("The plan is a last resort only to be tried if Kyrenna indeed escapes and the remains are discovered.")
	elseif e.message:findi("I will complete the ritual") and faction >= 44 then
		e.self:Say("It would seem we have no choice, and this is our only hope. I must first make a dark shroud. To do this I must stain it with the blood of an innocent.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	local faction = e.other:GetCharacterFactionLevel(404) -- True Spirit
	if faction >= 43 and item_lib.check_turn_in(e.trade, {item1 = 14376}) then
		e.self:Emote("reads the note, eyes widening in panic.")
		e.other:Faction(404, 1)
	elseif faction >= 51 and item_lib.check_turn_in(e.trade, {item1 = 14381}) then
		e.self:Say("Here, you take this shroud. You must now find the spirit of Glohnor and place this item on him.")
		e.other:Faction(404, 7)
		e.other:SummonItem(14377) -- Dark Shroud
	elseif faction >= 58 and item_lib.check_turn_in(e.trade, {item1 = 14379}) then
		e.self:Say("You've done it! Please accept this as well as my eternal gratitude.")
		e.other:Faction(404, 7)
		e.other:SummonItem(14370) -- Will of Innoruuk
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
