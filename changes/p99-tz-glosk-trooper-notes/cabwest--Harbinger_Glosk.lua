-- Source: cabwest/Harbinger_Glosk.pl
-- P99 audit: Necromancer Skullcap Quests
-- items: 18207, 12407, 12873, 12874, 4265, 4266

function event_spawn(e)
	local xloc = e.self:GetX()
	local yloc = e.self:GetY()
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50)
end

function event_enter(e)
	if e.other:HasItem(18207) then
		e.other:Message(MT.Yellow, "As your reptilian eyes adjust to the darkness of the room, an imposing Iksar turns towards you, addressing you with a sharp hiss. 'I am Harbinger Glosk. The time has come young one. You have chosen the path of the Necromancer. Open your inventory and read the note within. Once you are ready to begin your training, hand the note to me and we will continue.'")
	end
end

local function has_revenant_faction(e)
	return e.other:GetFaction(e.self) <= 3 -- kindly or better per P99
end

local function say_low_faction(e)
	e.self:Say("You have not yet earned the trust required of a revenant of the Brood.")
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("halts his chanting.")
		e.self:Say("You dare to interrupt me? You had best have a good reason. I care not for small talk.")
	elseif e.message:findi("new revenant") then
		if has_revenant_faction(e) then
			e.self:Say("Yes. You are. You shall do as I command. Take this. It is incomplete and must be ready for the emperor within the half season. You must find the Four Missing Gems. When you have them, then you will have to Quest for the Grand Forge of Dalnir. Within it's fire, all shall combine. Return the Sceptre to me with your Revenant Skullcap. Go.")
			e.other:SummonItem(12873) -- Unfinished Sceptre
		else
			say_low_faction(e)
		end
	elseif e.message:findi("forge of dalnir") then
		e.self:Emote("scratches his chin.")
		e.self:Say("I know little of it other than that it once belonged to the ancient Haggle Baron, Dalnir. From what I have read, its fires require no skill, but will melt any common forge hammer used. Dalnir was said to have called upon the ancients for a hammer which could tolerate the magickal flames.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18207}) then
		e.self:Say("Another apprentice has reached rebirth. You now have become one with the Brood of Kotiz. We study the ancient writing of Kotiz. Through his writing we have found the power of the dark circles. Listen well to the scholars within this tower and seek the Keepers Grotto for knowledge of our spells. This drape shall be the sign to all Iksar that you walk with the Brood. Now go speak with Xydoz.")
		e.other:SummonItem(12407)
		e.other:AddEXP(500)
		e.other:Faction(443, 100, 0)
		e.other:Faction(441, 25, 0)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 12874, item2 = 4265}) then
		e.self:Emote("presents to you a glowing skullcap.")
		e.self:Say("This is the treasured cap of the sorcerers of this tower. Let all gaze upon you in awe. You are what others aspire to be. I look forward to reading of your adventures, Sorceror " .. e.other:GetName() .. ".")
		e.other:SummonItem(4266) -- Sorcerer Skullcap
		e.other:Faction(441, 20, 0) -- Legion of Cabilis
		e.other:Faction(443, 20, 0) -- Brood of Kotiz
		e.other:AddEXP(10000)
		e.other:GiveCash(0, 0, 0, 2)
	elseif item_lib.check_turn_in(e.trade, {item1 = 14794}) then
		e.self:Say("Show this to Rixiz. He will test you.")
		e.other:SummonItem(14794)
	elseif item_lib.check_turn_in(e.trade, {item1 = 14793}) then
		e.self:Say("Xydoz. Take this to Xydoz. He will test you.")
		e.other:SummonItem(14793)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
