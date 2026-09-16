-- Converted from ProjectEQ Perl quest script.
-- Source: cabeast/Zazlan_Furscale.pl
-- P99 audit: Scaled Mystic Armor Quests
-- items: 3064, 10033, 14767, 14768, 4984, 3061, 10035, 14769, 14770, 4988, 3058, 10032, 14765, 14766, 4991, 3060, 10034, 14763, 14764, 4986

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings, youngling. Are you here seeking wisdom or are you here to [work]?")
	elseif e.message:findi("work") then
		e.self:Say("Ah! Excellent! Than you shall acquire wisdom THROUGH work! As a mystic, you will need to learn [arts of creation], and you can learn that by watching me work.")
	elseif e.message:findi("arts of creation") then
		e.self:Say("Yes yes... the arts of creation. You'll need to do some leg work in the fields to gather the materials for me to show you how to create [boots], [bracers], a [cloak], or [vambraces].")
	elseif e.message:findi("boots") then
		e.self:Say("I'll need you to bring me some banded boots, a fire emerald, some spirit caller beads, and a rhino hoof. Come back to me when you have all the components and then give them to me, then I'll show you how to make boots.")
	elseif e.message:findi("bracers") then
		e.self:Say("I'll need you to bring me a banded bracer, a ruby, a coercion implant, and some gooey adhesive. Bring all that back to me and I'll show you how to make a bracer.")
	elseif e.message:findi("cloak") then
		e.self:Say("To make a cloak for you, I'll need a banded cloak, a star ruby, a forest giant hammer, and some worn charbone. Good luck getting all those components together. Bring them back when you have them and I'll show you how to make your cloak.")
	elseif e.message:findi("vambraces") then
		e.self:Say("Ah! You want arm coverings? Well fetch me some banded sleeves, a sapphire, a frenzied gnawer tail, and some froglok treated planks.")
	end
end

local function reward(e, item_id)
	e.other:SummonItem(item_id)
	e.other:AddEXP(1000)
	e.other:Faction(445, 10, 0) -- Scaled Mystics
	e.other:Faction(441, 5, 0) -- Legion of Cabilis
	e.other:Faction(440, 5, 0) -- Cabilis Residents
	e.other:Ding()
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 3064, item2 = 10033, item3 = 14767, item4 = 14768}) then
		e.self:Say("Ah! Excellent! Now just watch... and... here! Now you know how to make your own boots! Take this pair in case you didn't actually learn anything.")
		reward(e, 4984) -- Scaled Mystic Boots
	elseif item_lib.check_turn_in(e.trade, {item1 = 3061, item2 = 10035, item3 = 14769, item4 = 14770}) then
		e.self:Say("What's this? Oh the parts for your bracer. Well just watch me work... and... done! Take these as an example of what a skilled craftsman can do. Strive for this perfection.")
		reward(e, 4988) -- Scaled Mystic Bracers
	elseif item_lib.check_turn_in(e.trade, {item1 = 3058, item2 = 10032, item3 = 14765, item4 = 14766}) then
		e.self:Say("Well you finally brought the parts to learn how to make your cloak. Just watch this... and... all done. It's not the best I've ever made, but it's fitting for a novice.")
		reward(e, 4991) -- Scaled Mystic Cloak
	elseif item_lib.check_turn_in(e.trade, {item1 = 3060, item2 = 10034, item3 = 14763, item4 = 14764}) then
		reward(e, 4986) -- Scaled Mystic Vambraces
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
