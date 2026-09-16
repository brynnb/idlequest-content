-- Converted from ProjectEQ Perl quest script.
-- Source: kithicor/Leaf_Falldim.pl
-- items: 3190, 3192, 3191

local function ivy_reward(e)
	e.self:Say("Very good, you have brought justice to these lands.")
	e.other:Faction(269, 30, 0)
	e.other:Faction(302, 30, 0)
	e.other:Faction(272, 30, 0)
	e.other:Faction(324, -60, 0)
	e.other:AddEXP(10000)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings. " .. e.other:GetName() .. "!  Respect the woods and all its inhabitants or face the wrath of the rangers.  Do not end up like [Maldyn Greenburn].")
	elseif e.message:findi("maldyn greenburn") then
		e.self:Say("Maldyn was once one of us.  He was the finest of archers.  Everyone aspired to be like him.  He soon was tempted to hunt.  The animals of these woods found themselves nothing more than moving targets for Maldyn's training.  We held a trial and exiled him to parts unknown.  He would take with him Morin's [Bow of Kithicor].  I was asked to find a worthy ranger to [retrieve the bow].")
	elseif e.message:findi("bow of kithicor") then
		e.self:Say("The Bow of Kithicor was carved from an ancient tree. It has great powers which were but a portion of the tree's mana. I seek a brave ranger to [retrieve the bow].")
	elseif e.message:findi("retrieve the bow") then
		e.self:Say("Search the lands of the Unkempt Druids in the Rathe Mountains.  I have heard of his arrows being found inside its territories and  of his death wish to hunt down its leader.  Retrieve the bow and return it to me and I shall give you the ivy etched gauntlets.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12321, item2 = 12320}) then
		e.other:SummonItem(3190)
		ivy_reward(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12305, item2 = 12306, gold = 2000}) then
		e.self:Say("Here are your boots.")
		e.other:SummonItem(3192)
		ivy_reward(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 10059, item2 = 12328}) then
		e.self:Say("Here are your leggings.")
		e.other:SummonItem(3191)
		ivy_reward(e)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
