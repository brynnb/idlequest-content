-- Converted from ProjectEQ Perl quest script.
-- Source: neriakc/Noxhil_V-Sek.pl
-- P99 audit: Scroll of G'han
-- items: 17930, 13389, 13021, 13022, 17934, 13395, 10124, 15355, 18890

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings, " .. e.other:GetName() .. "!  We of the Dead are proud to have you among us.  Your lineage is well known.  Still, you must learn to claw your way to the upper echelon.  There are many [menial tasks] to be performed before you can truly be inducted as a member.")
	elseif e.message:findi("menial tasks") then
		e.self:Say("You cannot avoid the toil of peons. We have all spent our time in the lower ranks. There are duties such as [collecting beetle eyes] or [courier duties].")
	elseif e.message:findi("innoruuk") then
		e.self:Say("He is the Prince of Hate. We are His vessels of destruction. There are no greater servants of Innoruuk than the Dead. His word is law. Once the Teir'Dal obtain the second half of the [scroll of G'han], all Norrath shall be enveloped by His glorious hate.")
	elseif e.message:findi("scroll of g'han") then
		if e.other:GetFaction(e.self) > 6 then
			e.self:Say("When you learn to serve the Dead, then I will find the time to speak of such things.")
		else
			e.self:Say("The scroll of G'han was scribed long ago by the great necromancer G'han. With it, we can commune directly with Innoruuk. Unfortunately, one portion of the scroll was taken from us by a rogue who was hired by the Koada'Dal. In Felwithe, it doth lie. The Indigo Brotherhood now attempts to reclaim it.")
		end
	elseif e.message:findi("collecting beetle eyes") then
		if e.other:GetFaction(e.self) <= 4 then
			e.self:Say("Take this chest.  It has been fitted with a mold designed to hold ten beetle eyes.  We require them for further experiments.  Do not return until you fill the chest.")
			e.other:SummonItem(17930)
		else
			e.self:Say("How dare you enter my presence?! In the name of the Dead I should strike you down!")
		end
	elseif e.message:findi("courier duties") then
		if e.other:GetFaction(e.self) <= 4 then
			e.self:Say("We require you to retrieve messages from our nearby agents. Periodically, you are required to contact the agent and ask if he has any messages for Neriak. If he does, you will return all correspondence to the designated party. Presently, we have enough runners. Here. You may see the list.")
			e.other:SummonItem(18890) -- Sealed List: Current Expeditionary Units
		else
			e.self:Say("How dare you enter my presence?! In the name of the Dead I should strike you down!")
		end
	elseif e.message:findi("other components") then
		if e.other:GetFaction(e.self) <= 4 then
			e.self:Say("Take this chest. This one must be filled with Kerra Isle Beetle eyes. Before you return the filled chest to me, be sure to also return with a wooly mammoth tusk. Be quick about it....")
			e.other:SummonItem(17934) -- Beetle Eye Chest container
		else
			e.self:Say("How dare you enter my presence?! In the name of the Dead I should strike you down!")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13389}) then
		if e.other:GetFaction(e.self) <= 4 then
			e.self:Say("Fantastic work, my child! We shall store these for further experiments. Take this as extra payment for a fine job. You have done so well I believe you can assist in obtaining two [other components].")
			e.other:Faction(239, 10, 0)
			e.other:Faction(303, 1, 0)
			e.other:Faction(278, -1, 0)
			e.other:Faction(275, -1, 0)
			e.other:Faction(245, -1, 0)
			e.other:Faction(1522, -20, 0)
			e.other:AddEXP(6400)
			e.other:GiveCash(0, 16, 0, 0)
			e.other:SummonItem(eq.ChooseRandom(13021, 13022))
		else
			e.self:Say("How dare you enter my presence?! In the name of the Dead I should strike you down!")
			e.other:SummonItem(13389)
		end
	elseif item_lib.check_turn_in(e.trade, {item1 = 13395, item2 = 10124}) then -- Beetle Eye Chest and Mammoth Tusks
		if e.other:GetFaction(e.self) <= 4 then
			e.self:Say("I was expecting a mammoth tusk and the combined beetle eye box! Excellent work, young one!  You are sure to be an asset to our faction.  Let us see if we can help you on your journey to power.  I believe this can be of assistance to a young necromancer of the Dead.")
			e.other:Faction(239, 5, 0)
			e.other:Faction(303, 5, 0)
			e.other:Faction(278, -10, 0)
			e.other:Faction(275, -10, 0)
			e.other:Faction(245, -10, 0)
			e.other:Faction(1522, -10, 0)
			e.other:AddEXP(17150)
			e.other:SummonItem(15355) -- Spell: Engulfing Darkness
		else
			e.self:Say("How dare you enter my presence?! In the name of the Dead I should strike you down!")
			e.other:SummonItem(13395)
			e.other:SummonItem(10124)
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
