-- Converted from ProjectEQ Perl quest script.
-- Source: qcat/Garuc_Anehm.pl
-- items: 5013, 5016, 7007, 1050, 13301, 13287, 9006, 17002, 2104, 7009, 15235, 13134

local function bloodsaber_reward(e, item_id)
	e.other:SummonItem(item_id)
	e.other:Ding()
	e.other:Faction(221, 10, 0)
	e.other:Faction(262, -1, 0)
	e.other:Faction(296, 1, 0)
	e.other:Faction(341, -2, 0)
	e.other:Faction(230, 1, 0)
	e.other:AddEXP(500)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome to the Shrine of Bertoxxulous! You appear to be [new to the shrine]. I do not remember seeing you around.")
	elseif e.message:findi("new to the shrine") then
		e.self:Say("New blood to spread Bertoxxulous' disease? We presently need the help of a [young shadowknight]. There are certain deeds which must be carried out.")
	elseif e.message:findi("young shadowknight") then
		e.self:Say("Then let your supreme task be the extermination of the Priests of Life. Know that they threaten the will of our Lord Bertoxxulous. For every fallen paladin and cleric of the Temple of Life. you shall rise within our ranks.  So... do you [loathe paladins]?")
	elseif e.message:findi("loathe paladins") then
		e.self:Say("As do we all. The paladins of Qeynos come from either the Hall of Thunder or the Temple of Life. We have put a bounty upon their heads. Destroy these knights and return either the Order of Thunder or the prayer beads of these inferior men. There has even been a report from [Commander Kane].")
	elseif e.message:findi("commander kane") and not e.message:findi("on duty") then
		e.self:Say("Kane Bayle is the Commander of the Qeynos Guard. He has found it advantageous to befriend the Bloodsabers. We share a [common goal]. He assists us in many ways. He has some new information to reveal.  Go and tell him you are a Bloodsaber. Do not speak with him while he is [on duty]!!")
	elseif e.message:findi("common goal") then
		e.self:Say("Kane Bayle and the leaders of this shrine all wish to overthrow the rule of Antonius Bayle. He, for power, and we for the glory of Bertoxxulous. From this city, our diseased lord shall appear and tread across the land spitting death from his mouth and deforming the land. His glory shall be eternal!")
	elseif e.message:findi("on duty") then
		e.self:Say("Kane is quartered within the gatehouse of Qeynos while on duty. At times he can also be found within this shrine.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13287}) then
		e.self:Say("Ha! You must have slain a member of the Knights of Thunder. These pitiful knights have been a thorn in our side for far too long. Take this reward and continue the work of Bertoxxulous.")
		bloodsaber_reward(e, 5013) -- Rusty Short Sword
	elseif item_lib.check_turn_in(e.trade, {item1 = 13296}) then
		e.self:Say("Fine work! One less threat to our shrine. Take this. It shall help you become a great asset to our shrine. Go forth and spread the disease.")
		bloodsaber_reward(e, 17001) -- Wrist Pouch
	elseif item_lib.check_turn_in(e.trade, {item1 = 13908}) then
		e.self:Say("You fool! Brother Trintle was our mole within the Priests of Life. Now you have killed him. For this you shall die!")
		e.other:Faction(221, -50, 0)
		e.other:Faction(262, 7, 0)
		e.other:Faction(296, -5, 0)
		e.other:Faction(341, 12, 0)
		e.other:Faction(230, -2, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 13134}) then
		e.self:Say("Hahaha.. I see you actually killed a respected, well-known citizen of Qeynos. No loss for them, but you are certainly a gain for our shrine. Maybe this shall do you some good. If not now, then surely later. You may need it when the Qeynos Guards hunt you down.")
		bloodsaber_reward(e, eq.ChooseRandom(9006, 17002, 2104, 7009, 13301, 15235))
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
