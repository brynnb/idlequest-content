-- Source: freportw/Lorme_Tredore.lua
-- P99 audit: Fleshy Orbs
-- items: 18740, 13559, 13951, 5353

local function arcane_newbie_note(e)
	e.self:Say(string.format("Welcome to the Academy of Arcane Sciences. I am Lorme Tredore, Master Magician. Here is our guild robe, wear it with pride and represent us well, young %s. Now, let's get to work.", e.other:GetName()))
	e.other:SummonItem(13559) -- Item: Used Violet Robe*
	e.other:Ding()
	e.other:Faction(220, 100, 0) -- Arcane Scientists
	e.other:Faction(281, 25, 0) -- Knights of Truth
	e.other:Faction(296, -15, 0) -- Opal Dark Briar
	e.other:Faction(330, -15, 0) -- The Freeport Militia
	e.other:AddEXP(100)
end

local function fleshy_orb_reward(e)
	e.self:Say("Ah, thank you for bringing this to me! I will make very good use of it. Here, take this small token of my appreciation in return. Guard Jenkins will no longer require it, as he was killed on the training field yesterday. tsk tsk tsk.")
	e.other:SummonItem(5353) -- Item: Fine Steel Scimitar
	e.other:Ding()
	e.other:Faction(341, 5, 0) -- Priests of Life
	e.other:Faction(280, 1, 0) -- Knights of Thunder
	e.other:Faction(262, 2, 0) -- Guards of Qeynos
	e.other:Faction(219, 1, 0) -- Antonius Bayle
	e.other:GiveCash(0, 12, 5, 0)
	e.other:AddEXP(100)
end

function event_trade(e)
	local item_lib = require("items")

	if item_lib.check_turn_in(e.trade, {item1 = 18740}) then -- A Tattered Note
		arcane_newbie_note(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 13951}) then -- Fleshy Orb
		if e.other:GetFaction(e.self) < 5 then
			fleshy_orb_reward(e)
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
