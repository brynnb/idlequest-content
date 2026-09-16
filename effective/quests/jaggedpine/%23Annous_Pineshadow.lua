-- Converted from ProjectEQ Perl quest script.
-- Source: jaggedpine/#Annous_Pineshadow.pl
-- items: 8962, 8956, 8964, 8963, 17135, 8966, 8967

local function galeweaver_state(e)
	local qglobals = eq.get_qglobals(e.other)
	return qglobals["galeweaver"]
end

local function reward_factions(e)
	e.other:Faction(1597, 10, 0)
	e.other:Faction(272, 10, 0)
	e.other:Faction(302, 10, 0)
	e.other:Faction(262, 10, 0)
end

function event_say(e)
	local state = galeweaver_state(e)
	if e.message:findi("hail") then
		e.self:Say("Good day to you, " .. e.other:GetName() .. ". I am Annous Pineshadow, high priest of The Rainkeeper and ambassador of Qeynos. It has been a [long] time since I last set foot within the Jaggedpine.")
	elseif e.message:findi("long") then
		e.self:Say("Sixty years -- give or take. This is the place of my birth and my home. Those who remained outside of the forest's confines were there to continue the faith and [sacred ways] of The Rainkeeper.")
	elseif e.message:findi("sacred ways") then
		e.self:Say("There are hundreds of different rites, ceremonies, prayers, and rituals. You must [have the faith in your heart] and truly wish to uphold the ways of the Rainkeeper.")
	elseif e.message:findi("faith in my heart") then
		e.self:Say("Perhaps, if [you are willing], I might guide you on a path that may lead to the discovery of such answers.")
	elseif e.message:findi("i am willing") then
		e.self:Say("Excellent, child. The first journey that you must embark on will result in the acquisition of the [Azure Idol of Karana].")
	elseif e.message:findi("azure idol of karana") then
		e.self:Say("You will seek one of these idols -- one that at present has no owner and was stolen by the bandit raiders. The man who possesses the idol is one known as Drayen Blackguard. You shall find him in the mountains of Rathe if our scouts are correct.")
	elseif e.message:findi("prove myself worthy") and state == "1" then
		e.self:Say("Then your endeavor shall continue, my child. Take this scroll -- to you now it holds no meaning but in due time you shall understand. Keep the scroll close to you until you have sought and successfully acquired the [Dormant Crystal Sphere] and [The Rainkeeper's Writ].")
		e.other:SummonItem(8962)
	elseif e.message:findi("dormant crystal sphere") and state == "1" then
		e.self:Say("There are several magical spheres throughout Norrath but this sphere is [unique to The Rainkeeper].")
	elseif e.message:findi("unique to the rainkeeper") and state == "1" then
		e.self:Say("I have heard rumors that the orb lies within the depths of Solusek's Eye -- nestled in the hands of a giant known as Neiroth the Tyrant. Find this ancient giant and retrieve the orb from him.")
	elseif e.message:findi("writ") and state == "1" then
		e.self:Say("The writ was lost to us sometime before the Jaggedpine was sealed. In the southern plain of Karana you will find the remnants of Naundruar, a once great priest, and with him, you shall find the writ.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	local state = galeweaver_state(e)
	if item_lib.check_turn_in(e.trade, {item1 = 8956}) then
		e.self:Say("Marvelously done, my friend. The idol's return by your hand bodes well indeed toward the success of your quest. If [you wish to prove yourself worthy] of the idol and further prove your faith as notable enough to belong to the sacred order of The Gale Weavers, then speak your pledge and your test shall continue.")
		e.other:AddEXP(10000)
		e.other:Ding()
		reward_factions(e)
		eq.set_global("galeweaver", "1", 0, "F")
	elseif state == "1" and item_lib.check_turn_in(e.trade, {item1 = 8964, item2 = 8963, item3 = 8962}) then
		e.self:Say("You have done well, my child. I have woven for you the Orb of the Gale -- your Orb of the Gale, but do not think that your journey ends here. You must seek the Essence of the Gale in the Plane of Sky.")
		e.other:AddEXP(10000)
		e.other:Ding()
		reward_factions(e)
		e.other:SummonItem(17135)
		eq.set_global("galeweaver", "2", 0, "F")
	elseif state == "2" and item_lib.check_turn_in(e.trade, {item1 = 8966}) then
		e.self:Say("You astound me, my child. Well done indeed. It is an honor to bestow upon you this, our sacred symbol, and welcome you into the order of The Gale Weavers.")
		e.other:AddEXP(10000)
		e.other:Ding()
		reward_factions(e)
		e.other:SummonItem(8967)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
