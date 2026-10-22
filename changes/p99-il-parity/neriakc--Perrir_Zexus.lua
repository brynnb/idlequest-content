-- Converted from ProjectEQ Perl quest script.
-- Source: neriakc/Perrir_Zexus.pl
-- P99: https://wiki.project1999.com/Innoruuk_Recommendation
-- P99: https://wiki.project1999.com/Innoruuk_Symbol_Quests
-- items: 18756, 13585, 18148, 13113, 14550, 1369

function event_spawn(e)
	local xloc = e.self:GetX()
	local yloc = e.self:GetY()
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50)
end

function event_enter(e)
	if e.other:HasItem(18756) then
		e.other:Message(MT.Yellow, "A sly looking Dark Elf turns to address you. 'Come to me, young Cleric. I am Perrir Zexus. Read the note in your inventory and hand it to me so that you may begin on the path of the Cleric. True power can be yours should you have the will to train hard enough!'")
	end
end

function event_say(e)
	local fac = e.other:GetFaction(e.self)

	if(fac > 5) then
		e.self:Say("You are worthless and pathetic! You could never be of service to our temple! Begone before your innards decorate our walls!")
	elseif(fac == 5) then
		e.self:Say("Although I sense the hate building within you, you have not yet done enough service to this temple to be trusted!")
	elseif(e.message:findi("hail")) then
		e.self:Say("Salutations, " .. e.other:GetName() .. "! Your devotion to our Lord Innoruuk is evident in your actions and on your soul. As a member of the Spires of Innoruuk, you are required to obtain and wear the symbol of your station among the clergy. I can award you the [hematite symbol of Innoruuk] worn by the initiates of the Spires.")
	elseif(e.message:findi("hematite symbol of innoruuk")) then
		e.self:Say("The forest beyond the gates of our grand city has been shaped by the magic of our Lord Innoruuk to be more hospitable to our kind. There are halfling druids in the service of Karana who have set up shrines there in hopes of restoring the forest to its former state. They could never succeed in their task with their feeble powers granted by their insignificant god, yet still, they are a nuisance. Bring me four of the holy symbols worn by the druids and I shall grant you the initiate symbol of Innoruuk.")
	end
end

local function innoruuk_recommendation_faction(e, multiplier)
	multiplier = multiplier or 1
	e.other:Faction(340, 100 * multiplier, 0) -- Priests of Innoruuk
	e.other:Faction(278, 15 * multiplier, 0) -- King Naythox Thex
	e.other:Faction(362, -35 * multiplier, 0) -- Priests of Marr
	e.other:Faction(226, -25 * multiplier, 0) -- Clerics of Tunare
	e.other:Faction(341, -15 * multiplier, 0) -- Priests of Life
	e.other:Faction(1522, -400 * multiplier, 0) -- Primordial Malice
end

function event_trade(e)
	local item_lib = require("items")

	if item_lib.check_turn_in(e.trade, {item1 = 18756}) then -- Tattered Note
		e.self:Say("Welcome, child of Hate. I am Perrir Zexus, High Priest. We all draw power from the very source that created us, the will of Innoruuk. Here, put on this tunic. It is the tunic of our guild.")
		e.other:SummonItem(13585)
		e.other:AddEXP(100)
		innoruuk_recommendation_faction(e)
		e.other:Ding()
	elseif e.other:GetFaction(e.self) <= 5 and item_lib.check_turn_in(e.trade, {item1 = 18148}) then -- Note of Recommendation
		e.self:Say(e.other:GetName() .. ", eh? My sister has a keen perception for seeing into a person's soul. You may store an abundance of hate, but hate can be devoted to different ideals. Prove to me your devotion to our Lord Innoruuk by bringing me the skullcap of a Leatherfoot Raider who has invaded our forest. Go, " .. e.other:GetName() .. ", and do as I have requested!")
		innoruuk_recommendation_faction(e, 2)
		e.other:AddEXP(100)
		e.other:Ding()
	elseif e.other:GetFaction(e.self) <= 5 and item_lib.check_turn_in(e.trade, {item1 = 13113}) then -- Leatherfoot Raider Skullcap
		e.self:Say("Fine work, " .. e.other:GetName() .. "! You are well on your way to reaping the rewards of the Spires of Innoruuk.")
		e.other:Faction(340, 10, 0) -- Priests of Innoruuk
		e.other:Faction(278, 1, 0) -- King Naythox Thex
		e.other:Faction(362, -3, 0) -- Priests of Marr
		e.other:Faction(226, -2, 0) -- Clerics of Tunare
		e.other:Faction(341, -1, 0) -- Priests of Life
		e.other:Faction(1522, -40, 0) -- Primordial Malice
		e.other:AddEXP(100)
		e.other:Ding()
	elseif e.other:GetFaction(e.self) <= 5 and item_lib.check_turn_in(e.trade, {item1 = 14550, item2 = 14550, item3 = 14550, item4 = 14550}) then -- Woven Grass Amulets
		e.self:Say("You have done well, young Initiate. I grant you this medallion invested with the divine hatred of Innoruuk. Wear it proudly as a representation of your importance to these sacred spires. Now if you will excuse me I must proceed with the burning of these pathetic halfling symbols of faith.")
		e.other:SummonItem(1369)
		e.other:AddEXP(2000)
		e.other:Ding()
		e.other:Faction(278, 7, 0) -- King Naythox Thex
		e.other:Faction(340, 50, 0) -- Priests of Innoruuk
		e.other:Faction(226, -12, 0) -- Clerics of Tunare
		e.other:Faction(341, -7, 0) -- Priests of Life
		e.other:Faction(362, -17, 0) -- Priests of Marr
		e.other:Faction(1522, -200, 0) -- Primordial Malice
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
