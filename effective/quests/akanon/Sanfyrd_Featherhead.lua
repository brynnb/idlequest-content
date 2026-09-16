-- Source: akanon/Sanfyrd_Featherhead.lua
-- P99 audit: Duster Models, Scrap Metal Quest
-- items: 17979, 13198, 5013, 5014, 5015, 5016, 5019, 5020, 12340, 10303, 2175, 9426, 28618, 29906, 28165, 15980, 12336, 12337, 12254, 12339, 13216, 13217, 17981, 6027

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings! I am the operator of this scrapyard. If you have any scrap metal, I would be glad to purchase it from you in loads of four. The Gemchoppers no longer allow me to accept blackbox fragments and micro servos.")
	elseif e.message:findi("princess joleena") then
		e.self:Say("No!! You cannot have my magic Fairie Wing!! I need it. I read somewhere within the great library that the magic wing from a fairie princess will restore my full head of hair. Look at me!! I am bald!! I have no [friends] at all.")
	elseif e.message:findi("friend") then
		e.self:Say("Oh. You are just saying that so you can get my fairie wing. I will make you a deal. I cannot rely on this wing forever. I will trade it with you if you could get me a case of hair tonic. If you are a true friend you [will fetch the hair tonic] for me.")
	elseif e.message:findi("hair tonic") then
		e.self:Say("Great!! Here you go, my friend. Take this crate and within you shall fill each slot with hair tonic. When all are combined within the crate, return it to me for your wing. I am not sure what the tonic was or where I got it. There is some writing on the crate, but I could not identify it.")
		e.other:SummonItem(17979) -- Item: Crate for Tonics
		e.other:Ding()
	end
end

local function gemchopper_scrap_faction(e)
	e.other:Faction(255, 3, 0) -- Faction: Gem Choppers
	e.other:Faction(333, 3, 0) -- Faction: King Ak`Anon
	e.other:Faction(288, 3, 0) -- Faction: Merchants of Ak`Anon
	e.other:Faction(238, -3, 0) -- Faction: Dark Reflection
	e.other:Faction(1604, -3, 0) -- Faction: Clan Grikbar
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 13198, item2 = 13198, item3 = 13198, item4 = 13198}) then
		e.self:Say("For your efforts I shall reward you")
		e.other:SummonItem(eq.ChooseRandom(5013, 5013, 5013, 5014, 5014, 5014, 5015, 5015, 5015, 5016, 5016, 5016, 5019, 5019, 5019, 5020, 5020, 5020, 12340, 12340, 10303, 2175))
		gemchopper_scrap_faction(e)
		e.other:AddEXP(1000)
		e.other:GiveCash(4, 5, 1, 0)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 9426, item2 = 28618, item3 = 29906, item4 = 28165}) then
		e.self:Say("I've been waiting for those.  Thank you, please take this!")
		e.other:SummonItem(15980) -- Note for Fimli
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 12336}) then
		e.self:Say("Huzzah!! You are my friend. Now you can take my old toupee and get it repaired. Just go to Freeport and ask Ping to [repair the toupee]. Hey!! You know what? He is the guy who sells the hair tonic!! I remember now. Well,.. Get my toupee repaired and I will give you the fairie wing.")
		e.other:SummonItem(12337) -- Item: Tattered Toupee
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 12254}) then
		e.self:Say("Double Huzzah!! You are a good friend " .. e.other:GetName() .. ". Now mayhaps I shall find myself a wife. Here pal, the fairy wing. I hope it can give you a great head of hair. You need it.")
		e.other:SummonItem(12339) -- Item: Glimmering Fairie Wing
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 13216, item2 = 13217}) then
		e.self:Say("Good. The citizens of Ak'Anon are safe from these little critters. They may have injured someone; that is why they were deactivated. Here is something I found in the scrapyard. I hope you can find a purpose for it.")
		e.other:SummonItem(eq.ChooseRandom(17981, 17981, 6027)) -- Bootstrutter's Framed Pack / Forging Hammer
		gemchopper_scrap_faction(e)
		e.other:GiveCash(0, 7, 0, 0)
		e.other:Ding()
		e.other:AddEXP(1000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
