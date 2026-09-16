-- Converted from ProjectEQ Perl quest script.
-- Source: neriakb/Narex_T-Vem.pl
-- items: 13886, 17972, 13113, 12257

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome to the Cauldron of Hate. If you are a young warrior, you have come to the right place. There are many [duties] to be performed. If you are a veteran of the blade, we welcome your return to service. Perhaps you return with a [Leatherfoot] skullcap?")
	elseif e.message:findi("duties") then
		if e.other:GetFaction(e.self) <= 4 then
			e.self:Say("I am so glad you asked. There is one matter of importance with which you may be able to assist. It seems an Erudite has made camp in Lavastorm. He is powerful and we do not expect you to slay him. Your mission is to cut off his supply line. I hope you will [accept the mission].")
		else
			e.self:Say("Go!! Return when you have done more to serve the Indigo Brotherhood of Neriak.")
		end
	elseif e.message:findi("accept the mission") then
		if e.other:GetFaction(e.self) <= 4 then
			e.self:Say("Go to the Lavastorm Mountain Range. It is a dangerous place, but the one you seek must leave by the direction you entered. He is a goblin. Apparently the Erudite is employing their strength. The fire goblin runner shall be an easy kill for you. At least, he should be. Return his runner pouch to me.")
		else
			e.self:Say("Go!! Return when you have done more to serve the Indigo Brotherhood of Neriak.")
		end
	elseif e.message:findi("leatherfoot") then
		if e.other:Class() == "Warrior" then
			e.self:Say("Where have you been? The halflings of Rivervale have an elite force of warriors. They are called the Leatherfoot Raiders. They have been infiltrating our glorious city of Neriak for quite some time. They must be exterminated! I must hire strong warriors who wish to [collect the bounty].")
		else
			e.self:Say("Go!! Return when you have done more to serve the Indigo Brotherhood of Neriak. Fewer Leatherfoot Raiders in Nektulos and a few Leatherfoot skullcaps in the palms of Master Narex shall prove your true warrior nature and loyalty to our house.")
		end
	elseif e.message:findi("collect the bounty") then
		e.self:Say("So you wish to collect the bounty on Leatherfoot Raiders? Then go into Nektulos and hunt them down. I shall pay a reward for no fewer than four Leatherfoot Raider skullcaps.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13886}) then
		if e.other:GetFaction(e.self) <= 4 then
			e.self:Say("Fine work. I trust the denizens of Lavastorm were not unkind. Please take this featherweight pouch as a reward. May it keep you fleet of foot.")
			e.other:SummonItem(17972)
			e.other:Faction(270, 2, 0)
			e.other:Faction(326, -5, 0)
			e.other:Faction(311, -5, 0)
			e.other:Faction(1522, -5, 0)
			e.other:AddEXP(17150)
		else
			e.self:Say("Go!! Return when you have done more to serve the Indigo Brotherhood of Neriak.")
			e.other:SummonItem(13886)
		end
	elseif item_lib.check_turn_in(e.trade, {item1 = 13113, item2 = 13113, item3 = 13113, item4 = 13113}) then
		if e.other:GetFaction(e.self) <= 5 then
			e.self:Say("Yes, you have done well. Take this, and slay more!")
			e.other:SummonItem(12257)
			e.other:GiveCash(0, 0, 4, 0)
			e.other:Faction(270, 2, 0)
			e.other:Faction(326, -5, 0)
			e.other:Faction(311, -5, 0)
			e.other:Faction(1522, -5, 0)
			e.other:AddEXP(250)
		else
			e.self:Say("Go!! Return when you have done more to serve the Indigo Brotherhood of Neriak.")
			e.other:SummonItem(13113)
			e.other:SummonItem(13113)
			e.other:SummonItem(13113)
			e.other:SummonItem(13113)
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
