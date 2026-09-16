-- Converted from ProjectEQ Perl quest script.
-- Source: neriakc/Ithvol_K-Jasn.pl
-- items: 12497, 1369, 1370, 12499, 12498, 19029, 1371

local function innoruuk_faction(e)
	e.other:Faction(278, 10, 0)
	e.other:Faction(340, 10, 0)
	e.other:Faction(226, -30, 0)
	e.other:Faction(341, -30, 0)
	e.other:Faction(362, -30, 0)
	e.other:Faction(1522, -30, 0)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail, " .. e.other:GetName() .. "! I sense the gift of hatred in your aura. What status do you hold within these Spires?")
	elseif e.other:HasItem(1369) and e.message:findi("initiate") then
		e.self:Say("Well met, Initiate " .. e.other:GetName() .. ". If you desire to raise your station in this temple, I have a task for you. Are you willing to accept the task I am about to set before you?")
	elseif e.other:HasItem(1369) and e.message:findi("willing") then
		e.self:Say("As an initiate of the Spires, you have proven your hatred of the halflings who are desecrating our forest with their feeble shrines and camps. They persist in their hopeless task and seem to anticipate many of our tactics against them. Go out into the Nektulos and slay the one called Master Whoopal. Take his head to Draxiz N'Ryt so that he may probe the brain.")
	elseif e.other:HasItem(1370) and e.message:findi("disciple") then
		e.self:Say("I have an important task for a disciple of Hate such as yourself. It is no secret that King Naythox Thex wishes to expand the Teir'Dal Empire to the continent of Faydwer. We have a camp established in the Lesser Faydark near the stronghold of the vampire lord, Mayong Mistmoore. The camp is constantly under siege by the Fier'Dal and Koada'Dal and must rely on the support of Neriak for supplies necessary to survival. Are you willing to serve your King and Empire by delivering the provisions?")
	elseif e.other:HasItem(1370) and e.message:findi("deliver the provisions") then
		e.self:Say("The provisions are crated and prepared for shipment by Dran Slug Rembor. Go to his establishment in the Foreign Quarter and tell him Ithvol sent you. Make haste, young disciple of Hate! The fate of the Empire hangs upon our support of the Faydark Camp!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12497, item2 = 1369}) then
		e.self:Emote("You have focused the hate within you and discovered that hate and rage are not the same. Hate can be calculating and deceptive. For your service in defending the Kingdom of King Naythox Thex from the halfling invaders, I award you the disciple symbol of Innoruuk. Wear it with pride, " .. e.other:GetName() .. ".")
		e.other:SummonItem(1370)
		e.other:AddEXP(4000)
		innoruuk_faction(e)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12499, item2 = 12498, item3 = 19029, item4 = 1370}) then
		e.self:Say("Your devotion to the ideals of hatred and your service to our King Naythox Thex has proven your usefulness within these spires and within our great city. I award you the Regent Symbol of Innoruuk. Congratulations, Regent " .. e.other:GetName() .. "!")
		e.other:SummonItem(1371)
		e.other:AddEXP(8000)
		innoruuk_faction(e)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
