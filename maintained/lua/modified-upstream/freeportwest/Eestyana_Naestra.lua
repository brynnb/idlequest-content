-- Source: freeportwest/Eestyana_Naestra.lua
-- P99 audit: Errand for Wolten
-- items: 18822, 9985, 18804, 6016, 13296, 18735, 13554, 13003

function event_spawn(e)
	local xloc = e.self:GetX()
	local yloc = e.self:GetY()
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50)
end

function event_enter(e)
	if e.other:HasItem(18735) then
		e.other:Message(MT.Yellow, "As you bask in the majesty of the Temple of Marr, an important looking individual, clad in shining metal armor turns to greet you. 'I can spot a new recruit a mile a way. Welcome to the Temple of Marr. I am Eastyana Naestra. Read the note in your inventory and hand it to me to begin your training. I wish you the best of luck.'")
	end
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome to the Hall of Truth!  May the will of Mithaniel Marr guide you through life.  We are glad to see that you have an interest in our ways.  Please speak with any of my priests or knights and they shall help you find your faith.")
	elseif e.message:findi("militia") then
		e.self:Say("The Freeport Militia is nothing more than a ragtag band of mercenaries and convicts. They act as the guards of this troubled city. Be well aware that they are not the honorable guards you may think they are. They are commanded by Sir Lucan D'Lere, the self-proclaimed ruler of Freeport. We of the Hall of Truth shall set this city free from the grip of the Militia one day. It is our duty as Knights of Truth.")
	end
end

local function hall_of_truth_faction(e)
	e.other:Faction(281, 10, 0) -- Faction: Knights of Truth
	e.other:Faction(271, -15, 0) -- Faction: Dismal Rage
	e.other:Faction(330, -15, 0) -- Faction: The Freeport Militia
	e.other:Faction(362, 10, 0) -- Faction: Priests of Marr
	e.other:Faction(311, 10, 0) -- Faction: Steel Warriors
end

function event_trade(e)
	local item_lib = require("items")

	if item_lib.check_turn_in(e.trade, {item1 = 18822}) then
		e.self:Say("You must be the young member of the Hall of Truth who was sent by Theron. I am glad to see you avoided any interference. Please take this as a reward for your service.")
		e.other:SummonItem(9985) -- Item: Spell: Courage*
		e.other:Ding()
		hall_of_truth_faction(e)
		e.other:AddEXP(500)
		e.other:GiveCash(9, 0, 0, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 18804}) then
		e.self:Say("Thank you, defender of Karana! We have heard rumors of the followers of Bertoxxulous gaining knowledge of our knight who infiltrated the ranks of the [Militia]. They would have tried to sell the information to the Militia. We will inform our knight immediately. As for you, here is a donation to your journey's expenses. Stay clear of the Freeport Militia. There is no doubt they have learned of your alliance with us.")
		e.other:SummonItem(eq.ChooseRandom(6016, 13296, 13003)) -- Rusty Morning Star / Prayer Beads / Small Lantern
		e.other:Ding()
		hall_of_truth_faction(e)
		e.other:AddEXP(1000)
		e.other:GiveCash(0, 0, 0, 1)
	elseif item_lib.check_turn_in(e.trade, {item1 = 18735}) then -- Tattered Note
		e.self:Say("The Truthbringer welcomes you into his life, here is the tunic of Marr. Wear it with pride and be sure to conduct yourself with valor.")
		e.other:SummonItem(13554) -- Faded Purple Tunic*
		e.other:Ding()
		e.other:Faction(281, 100, 0)
		e.other:Faction(271, -15, 0)
		e.other:Faction(330, -15, 0)
		e.other:Faction(362, 20, 0)
		e.other:Faction(311, 10, 0)
		e.other:AddEXP(100)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
