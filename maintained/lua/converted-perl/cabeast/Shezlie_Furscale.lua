-- Converted from ProjectEQ Perl quest script.
-- Source: cabeast/Shezlie_Furscale.pl
-- items: 3056, 10032, 14777, 14778, 4989, 3062, 10035, 14773, 14774, 4985, 3063, 10033, 14775, 14776, 4987, 3053, 10034, 14771, 14772, 4990

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Be careful around here. " .. e.other:GetName() .. ". Injured broodlings are no use to anyone. Many of these structures are yet unstable and could fall at any time. If you're a mystic, I can teach you how to [protect] yourself.")
	elseif e.message:findi("protect") then
		e.self:Say("Yes indeed. As a broodling, you will need some protection to avoid any... unfortunate accidents. Should you wish, I can fashion some [armor] for you from some basic components. Provided you risk your life gathering them for me first.")
	elseif e.message:findi("armor") then
		e.self:Say("Armor, indeed. I can fashion protection for your [chest], [hands], [legs], or [head].")
	elseif e.message:findi("chest") then
		e.self:Say("To make a breastplate for you, you will have to bring me some banded mail, a star ruby, some watchman's spectacles, and some nectar of isolation. Now hurry back.")
	elseif e.message:findi("hands") then
		e.self:Say("For gauntlets, I will need some banded gauntlets, a ruby, some venomous parchment, and a warlord drawing pen.")
	elseif e.message:findi("legs") then
		e.self:Say("If you want to protect your legs with some greaves, then bring me some banded leggings, a fire emerald, a sarnak recruitment letter, and an exiled iksar head.")
	elseif e.message:findi("head") then
		e.self:Say("For a helment, bring me a banded helm, a sapphire, Bargynn's Digger, and Sythrax building plans.")
	end
end

local function reward(e, item_id, exp)
	e.other:SummonItem(item_id)
	e.other:AddEXP(exp)
	e.other:Faction(445, 10, 0)
	e.other:Faction(441, 5, 0)
	e.other:Faction(440, 5, 0)
	e.other:Ding()
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 3056, item2 = 10032, item3 = 14777, item4 = 14778}) then
		e.self:Say("Ah. Very good. Take this breastplate for your own good.")
		reward(e, 4989, 2000)
	elseif item_lib.check_turn_in(e.trade, {item1 = 3062, item2 = 10035, item3 = 14773, item4 = 14774}) then
		e.self:Say("Hmmm? Oh. Your gauntlets. Yes. Here you are. Now be careful.")
		reward(e, 4985, 1000)
	elseif item_lib.check_turn_in(e.trade, {item1 = 3063, item2 = 10033, item3 = 14775, item4 = 14776}) then
		e.self:Say("Ahhh yes. These will protect your legs from the threat of tables.")
		reward(e, 4987, 1000)
	elseif item_lib.check_turn_in(e.trade, {item1 = 3053, item2 = 10034, item3 = 14771, item4 = 14772}) then
		e.self:Say("Take this helment and keep your head down when you leave. The door is a little low.")
		reward(e, 4990, 1000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
