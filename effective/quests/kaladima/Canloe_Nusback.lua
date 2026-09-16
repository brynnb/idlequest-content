-- Converted from ProjectEQ Perl quest script.
-- Source: kaladima/Canloe_Nusback.pl
-- items: 13318, 2113, 2114, 2115, 2116, 2117, 2118, 2119, 2120, 2121, 2122, 2123, 2124, 13319, 10018, 5024, 6014, 10017

local function random_training_item()
	return eq.ChooseRandom(2113, 2114, 2115, 2116, 2117, 2118, 2119, 2120, 2121, 2122, 2123, 2124)
end

local function random_shoulderpads_item()
	return eq.ChooseRandom(10018, 5024, 6014, 2124, 2120, 2116, 2119, 10017)
end

local function random_digit()
	return eq.ChooseRandom(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
end

local function belt_reward(e, count, faction, exp)
	e.self:Say("Good work, warrior! Now continue with your training. Only on the battlefield can one become a great warrior.")
	for _ = 1, count do
		e.other:SummonItem(random_training_item())
	end
	local copper = 0
	local silver = 0
	for _ = 1, count do
		copper = copper + random_digit()
		silver = silver + random_digit()
	end
	e.other:GiveCash(copper, silver, count, 0)
	e.other:Ding()
	e.other:Faction(312, faction, 0)
	e.other:Faction(274, faction, 0)
	e.other:Faction(293, faction, 0)
	e.other:Faction(290, faction, 0)
	e.other:Faction(232, -faction * 3, 0)
	e.other:AddEXP(exp)
end

local function shoulder_reward(e, count, faction, exp)
	e.self:Say("Good Work, warrior! Now continue with your training. Only on the battlefield can one become a great warrior.")
	for _ = 1, count do
		e.other:SummonItem(random_shoulderpads_item())
	end
	e.other:GiveCash(5 * count, 0, 3 * count, 0)
	e.other:Ding()
	e.other:Faction(312, faction, 0)
	e.other:Faction(274, faction, 0)
	e.other:Faction(293, faction, 0)
	e.other:Faction(290, faction, 0)
	e.other:Faction(232, -faction * 3, 0)
	e.other:AddEXP(exp)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Step forward and speak up, young " .. e.other:GetName() .. "! Kaladim can always use another warrior. Are you [ready to serve Kaladim] or has a yellow streak appeared down your back?")
	elseif e.message:findi("ready to serve kaladim") then
		e.self:Say("Then serve you shall. Let your training begin on the battlefields of Faydwer. Seek out and destroy all [Crushbone orcs]. Return their belts to me. I shall also reward you for every two orc legionnaire shoulder pads returned. A warrior great enough to slay one legionnaire shall surely have no problem with another. Go, and let the cleansing of Faydwer begin.")
	elseif e.message:findi("crushbone orcs") then
		e.self:Say("The army of the Crushbone orcs is deadly indeed. They are great military strategists. It was a legion of them that brought down the great [Trondle Ogrebane]. Speak with Furtog Ogrebane about the Crushbones. He has need of warriors such as you.")
	elseif e.message:findi("trondle ogrebane") then
		e.self:Say("Trondle Ogrebane is the legendary dwarven warrior who single-handedly exterminated the ogre clan called the [Mudtoes]. He was recently killed in battle. It took an entire legion of Crushbone orcs to bring him down. Furtog is still fuming about that.")
	elseif e.message:findi("mudtoes") then
		e.self:Say("The Mudtoes were a small clan of ogres. They lived somewhere in the Butcherblock Mountains. They had an insatiable appetite for dwarves. They were finally destroyed by the hand of Trondle Ogrebane.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13318, item2 = 13318, item3 = 13318, item4 = 13318}) then
		belt_reward(e, 4, 40, 18400)
	elseif item_lib.check_turn_in(e.trade, {item1 = 13318, item2 = 13318, item3 = 13318}) then
		belt_reward(e, 3, 30, 13800)
	elseif item_lib.check_turn_in(e.trade, {item1 = 13318, item2 = 13318}) then
		belt_reward(e, 2, 20, 9200)
	elseif item_lib.check_turn_in(e.trade, {item1 = 13318}) then
		belt_reward(e, 1, 10, 4600)
	elseif item_lib.check_turn_in(e.trade, {item1 = 13319, item2 = 13319, item3 = 13319, item4 = 13319}) then
		shoulder_reward(e, 2, 20, 64000)
	elseif item_lib.check_turn_in(e.trade, {item1 = 13319, item2 = 13319}) then
		shoulder_reward(e, 1, 10, 32000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
