-- Modified from ProjectEQ Lua to align Leatherfoot Raiders with P99.
-- Source: rivervale/Marshal_Anrey.lua
-- P99: https://wiki.project1999.com/Leatherfoot_Raiders
-- items: 13761, 13756, 13075, 13749, 13941, 13942, 12259

local function guardians_amiable_or_better(e)
	return e.other:GetFaction(e.self) <= 4
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Stand at attention!! You don't look fit enough to toe-wrestle my grandma!! You cannot be in my squad!! Are you [petitioning] or are you a [visitor]?")
	elseif e.message:findi("visitor") then
		e.self:Say("Well, why didn't you say so?! Forgive me for hollering. Allow me to introduce myself. I am Marshal Anrey Leadladle, commander of the [Leatherfoot Raiders].")
	elseif e.message:findi("petitioning") then
		e.self:Say("So you want to be a [Leatherfoot Raider]? What kind of joke is this? Look at you! You're a mess! Where are you [from]?")
	elseif e.message:findi("leatherfoot raider") then
		e.self:Say("You must be a visitor. The Leatherfoot Raiders are the elite force of the Guardians of the Vale. I command them. It is good to meet an outsider.")
	elseif e.message:findi("from rivervale") or e.message:lower() == "from" then
		e.self:Say("So you're from Rivervale?!! You must be some kind of freak. No halfling from Rivervale would look, smell and act anything like you. Well, freak, if you think you're stout enough to be a Leatherfoot Raider, you prove it!! You travel the lands and return to me a polar bear skin, a grizzly bear skin, a shark skin and an alligator skin. Then maybe, just maybe, I will let you wear the cap of a Leatherfoot Raider.")
	end
end

function event_trade(e)
	local item_lib = require("items")

	if item_lib.check_turn_in(e.trade, {item1 = 13761, item2 = 13756, item3 = 13075, item4 = 13749}) then -- Polar Bear Skin, Thick Grizzly Bear Skin, Shark Skin, Alligator Skin
		if guardians_amiable_or_better(e) then
			e.self:Say("So I see the young troll has become a young warrior. You have stepped up to the challenge of the Leatherfoot Raiders, you may wear the petitioners Skullcap, but to receive the true cap of the Raiders, bring me the Dirk of a fallen Neriak Dragoon and the cap I have given you. Only then can I be sure that you can truly be one of the few and bold, the Leatherfoot Raiders.")
			e.other:SummonItem(13941) -- Leatherfoot Skullcap
			e.other:Ding()
			e.other:AddEXP(1000)
			e.other:GiveCash(8, 1, 0, 0)
			e.other:Faction(263, 25, 0) -- Guardians of the Vale
			e.other:Faction(286, 3, 0) -- Mayor Gubbin
			e.other:Faction(355, 2, 0) -- Storm Reapers
			e.other:Faction(334, -3, 0) -- Dreadguard Outer
		else
			e.self:Say("You have not yet earned enough trust with the Guardians of the Vale to petition the Leatherfoot Raiders.")
			e.other:SummonItem(13761)
			e.other:SummonItem(13756)
			e.other:SummonItem(13075)
			e.other:SummonItem(13749)
		end
	elseif item_lib.check_turn_in(e.trade, {item1 = 13941, item2 = 13942}) then -- Leatherfoot Skullcap, Dragoon Dirk
		if guardians_amiable_or_better(e) then
			e.self:Say("Congratulations my young deputy. Welcome into the brotherhood of the Leatherfoot Raiders. You have earned your skullcap. Wear it with pride. You are now one of the elite. Remember our motto 'Those who risk, prevail'!")
			e.other:SummonItem(12259) -- Leatherfoot Raider Skullcap
			e.other:Ding()
			e.other:AddEXP(5000)
			e.other:GiveCash(7, 3, 2, 1)
			e.other:Faction(263, 50, 0) -- Guardians of the Vale
			e.other:Faction(286, 7, 0) -- Mayor Gubbin
			e.other:Faction(355, 5, 0) -- Storm Reapers
			e.other:Faction(292, 7, 0) -- Merchants of Rivervale
			e.other:Faction(334, -7, 0) -- Dreadguard Outer
		else
			e.self:Say("You have not yet earned enough trust with the Guardians of the Vale to become a Leatherfoot Raider.")
			e.other:SummonItem(13941)
			e.other:SummonItem(13942)
		end
	end

	item_lib.return_items(e.self, e.other, e.trade)
end
