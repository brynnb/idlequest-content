-- P99 audit: Goblin Raiders / Goblin Battlemasters
-- items: 12922, 12923, 9006, 12924, 12925, 12926, 12927, 12928, 12929, 12930, 12931, 12932, 12933

local faydark_ringmail_rewards = { 12924, 12925, 12926, 12927, 12928, 12929, 12930, 12931, 12932, 12933 }

local function firiona_vie_factions(e)
	e.other:Faction(248, 1, 0) -- Inhabitants of Firiona Vie
	e.other:Faction(326, 1, 0) -- Emerald Warriors
	e.other:Faction(312, 1, 0) -- Storm Guard
	e.other:Faction(441, -1, 0) -- Legion of Cabilis
	e.other:Faction(313, -1, 0) -- Pirates of Gunthak
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail!! Beware of the [goblin raiders] roaming the plains outside of Firiona Vie. They have caused much trouble and continue to assault this outpost.")
	elseif e.message:findi("goblin raiders") then
		e.self:Say("The goblin raiders have been quite a nuisance to my trackers. I implore you to aid my men and lessen the presence of the vile beasts. Bring me proof that you have taken at least four of these raiders down. You shall earn the respect of this outpost and insure your own well-being.")
	elseif e.message:findi("goblin battlemasters") then
		e.self:Say("The goblin battlemasters direct many of the attacks against our outpost. Bring me four of their bracers and I will reward you with a piece of armor crafted in Felwithe for the swiftly moving rangers of this outpost.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12922, item2 = 12922, item3 = 12922, item4 = 12922}) then
		e.self:Say("You serve this outpost well. Here is a small reward. You should try and hunt down Goblin Battlemasters. I have very few resources to send into the plains to track them down. Perhaps you can help us.")
		e.other:SummonItem(9006) -- Wooden Shield
		e.other:GiveCash(0, 0, 8, 0)
		firiona_vie_factions(e)
		e.other:AddEXP(100)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 12923, item2 = 12923, item3 = 12923, item4 = 12923}) then
		e.self:Say("Good work!! Please accept this piece of armor.  It was crafted in Felwithe for the swiftly moving rangers of this outpost.")
		e.other:SummonItem(faydark_ringmail_rewards[math.random(#faydark_ringmail_rewards)])
		firiona_vie_factions(e)
		e.other:AddEXP(100)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
