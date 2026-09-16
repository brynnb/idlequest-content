-- Converted from ProjectEQ Perl quest script.
-- Source: neriaka/Uglan.pl
-- items: 13357

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Me Uglan. Mighty ogre. Member of Crakneks. We crush for dark elves. Do you [like dark elves] or they be [mean] to you?")
	elseif e.message:findi("like dark elves") then
		e.self:Say("Me love friends Dark Elves.")
	elseif e.message:findi("mean") then
		e.self:Say("You smart person. Me know Dark Elves are not friendly. They just use Ogres. Me not like Neriak anymore.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13357}) then
		if e.other:GetRace() == 10 then -- Ogre
			e.self:Say("You from Oggok. Me waiting for you. Me know dark elves have dark plan for ogres. We must stop plan. You must go to Nektulos Forest. Wait for blue orc. He deliver message for dark elf king. Not good. You kill blue orc runners. If message on them then you take to Lork in Oggok. Ogres must know plan.")
			e.other:Ding()
			e.other:Faction(239, 5, 0)
			e.other:Faction(303, 1, 0)
			e.other:Faction(278, -1, 0)
			e.other:Faction(275, -1, 0)
			e.other:Faction(245, -1, 0)
			e.other:Faction(1522, -10, 0)
			e.other:AddEXP(500)
		else
			e.self:Say("Wat dis? Lork make deese steins. Dat means he tink you strong enuf for speshul quest me have for you. Me and Lork think ders something going on between dese darkies and the orcses in Crushbone. Someting bad for us Ogres. We need you to go mountains where da dorfs live. There be a blue orc runner wif darkie letters Lork wants. Bring Lork letters.")
			e.other:Ding()
			e.other:Faction(228, 10, 0)
			e.other:Faction(232, 10, 0)
			e.other:Faction(261, -10, 0)
			e.other:AddEXP(500)
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
