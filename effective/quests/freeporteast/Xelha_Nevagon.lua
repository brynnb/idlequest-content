-- Source: freeporteast/Xelha_Nevagon.lua
-- P99 audit: Assist the Great Xelha, Xelha's Cyclops Eye
-- items: 13099, 12247, 10307, 15338, 13073, 15331

local function xelha_faction(e)
	e.other:Faction(271, 1, 0) -- Dismal Rage
	e.other:Faction(281, -1, 0) -- Knights of Truth
	e.other:Faction(296, 1, 0) -- Opal Darkbriar
end

function event_say(e)
	local fac = e.other:GetFaction(e.self)
	if e.message:findi("hail") then
		e.self:Say("A new recruit to our cause.  Just what I have been waiting for!  How would you like to serve the great Xelha Nevagon? I need an apprentice necromancer to [assist the great Xelha].")
	elseif e.message:findi("assist the great xelha") then
		if fac <= 4 then
			e.self:Say("Fantastic. Stick with me and you shall ascend in our ranks quickly. I am in need of some components for new spells. Will you collect them for me? I shall need four each of the following - fire beetle eyes, bone chips and spiderling silk. Fetch these items for me at once. Well..? Did not you hear the great Xelha? Begone!")
		else
			e.self:Say("Oh look..a talking lump of refuse..how novel!")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	local fac = e.other:GetFaction(e.self)

	if item_lib.check_turn_in(e.trade, { item1 = 13073, item2 = 13073, item3 = 13073, item4 = 13073 }) then -- Bone Chips
		e.self:Say("Excellent work! You are quite the little helper. Here you go, then. A little something for your little work. Your service to me has caused Innoruuk to look upon you favorably. Your faith in our group has grown. Continue the work.")
		e.other:Ding()
		xelha_faction(e)
		e.other:AddEXP(20)
		e.other:GiveCash(0, 0, 1, 0) -- P99: 1 gold
	elseif fac <= 4 and item_lib.check_turn_in(e.trade, { item1 = 10307, item2 = 10307, item3 = 10307, item4 = 10307 }) then -- Fire Beetle Eye
		e.self:Say("This is a good sight. I needed these to complete the current mixture. Bah!! I shall reward you for this small, very small, deed!! I pass on to you the knowledge of summoning. The more you serve, the more your faith in Innoruuk grows.")
		e.other:SummonItem(eq.ChooseRandom(15338, 15331)) -- Spell: Cavorting Bones or Spell: Reclaim Energy
		e.other:Ding()
		xelha_faction(e)
		e.other:AddEXP(40)
		e.other:GiveCash(0, 5, 0, 0) -- P99: 5 silver
	elseif fac <= 4 and item_lib.check_turn_in(e.trade, { item1 = 13099, item2 = 13099, item3 = 13099, item4 = 13099 }) then -- Spiderling Silk
		e.self:Say("Let's see here. One.. two.. three.. and.. four. Great!! Just enough for my needs. You are serving Xelha well. I give you Xelha's Sparkler. It is not much, but neither are you. You know what I really need is a cyclops eye. That would be worthy of a great reward.")
		e.other:SummonItem(12247) -- Xelha's Sparkler
		e.other:Ding()
		xelha_faction(e)
		e.other:AddEXP(60)
		e.other:GiveCash(0, 3, 0, 0) -- P99: 3 silver
	end

	item_lib.return_items(e.self, e.other, e.trade)
end
