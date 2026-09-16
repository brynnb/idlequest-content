-- Converted from ProjectEQ Perl quest script, with later-era tradeskill-book
-- dialogue omitted for Classic/Kunark IdleQuest scope.
-- Source: kaladimb/Mater.pl
-- items: 13316, 12161, 18767, 13516

local function trusted_miner(e)
	return e.other:GetFaction(e.self) <= 4
end

local function not_trusted(e)
	if e.other:GetFaction(e.self) <= 5 then
		e.self:Say("Don't take this personally, but I can't quite trust you with such matters. Maybe a few less Butcherblock bandits would prove your worth.")
	else
		e.self:Say("The word around the mines is that you are not to be trusted. You'd best leave before my dagger finds a new home in your back.")
	end
end

function event_say(e)
	if e.message:findi("hail") then
		if e.other:GetFaction(e.self) <= 7 then
			e.self:Say("Welcome to the mines of Kaladim!")
		else
			e.self:Say("The word around the mines is that you are not to be trusted. You'd best leave before my dagger finds a new home in your back.")
		end
	elseif e.message:findi("ready to earn") and (e.message:findi("mining pick 628") or e.message:findi("miners pick 628")) then
		if trusted_miner(e) then
			e.self:Say("So you have heard of Mining Pick 628 and feel you are ready to wield one? You shall earn one with the return of the ogre head of [Boog Mudtoe] and the 300 gold pieces he still owes me. Don't return unless you have the head and the 300 gold!!")
		else
			not_trusted(e)
		end
	elseif e.message:findi("boog mudtoe") then
		if trusted_miner(e) then
			e.self:Say("Boog Mudtoe is one of the last remaining ogres of the Mudtoe clan. We helped him escape the assault of the Stormguard for a small fee. Unfortunately for him, we have come to believe his head to be more valuable than the fee. We hear there is someone near the port of Butcherblock who knows of the Mudtoe's whereabouts.")
		else
			not_trusted(e)
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13316, gold = 300}) then
		if trusted_miner(e) then
			e.self:Say("Well done! I didn't think you had it in you! As promised, here is your pick.")
			e.other:Faction(322, 10, 0)
			e.other:Faction(223, -10, 0)
			e.other:Faction(379, -10, 0)
			e.other:Faction(241, 10, 0)
			e.other:Faction(244, -10, 0)
			e.other:AddEXP(5000)
			e.other:SummonItem(12161)
		else
			not_trusted(e)
			e.other:SummonItem(13316)
			e.other:GiveCash(0, 0, 300, 0)
		end
	elseif item_lib.check_turn_in(e.trade, {item1 = 18767}) then
		e.self:Say("Ah, welcome! We could use some fresh blood around here. The name's Mater, and I run this little outfit. Work hard for me, and I will reward you well. Cross me, and you'll find yourself buried under the mine cap.")
		e.other:SummonItem(13516)
		e.other:AddEXP(100)
		e.other:Faction(322, 100, 0)
		e.other:Faction(223, -5, 0)
		e.other:Faction(379, -5, 0)
		e.other:Faction(241, 5, 0)
		e.other:Faction(244, -15, 0)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
