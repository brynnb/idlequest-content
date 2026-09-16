-- IdleQuest starting guild note turn-in plus P99 "The Rogue Take".
-- name: Eolorn_J`Axx
-- P99: https://wiki.project1999.com/The_Rogue_Take
-- items: 18752, 13581, 18844, 13891, 1051

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("It is good to see new blood in our halls. I am the leader of this house. If you are looking for guidance, seek out the masters within. I rarely appoint tasks to new recruits, unless I need to retrieve the [foreign take].")
	elseif e.message:findi("foreign take") then
		e.self:Say("We have rogues operating in a few great cities. We send young rogues to retrieve the monthly take. We have been awaiting the Freeport delivery. The last youth I sent must have been killed along the way. I will need a new runner to [retrieve the chest].")
	elseif e.message:findi("retrieve the chest") then
		e.self:Say("You seem able enough. Here. Take this note to Freeport. Go through the Commonlands and be careful not to encounter any Freeport guards. There is a network of aqueducts accessible through hidden passages. Search the outside walls of Freeport. Take the note to Giz. She will meet you at night, on an island in the harbor. Good luck.")
		e.other:SummonItem(18844) -- Sealed Letter, Letter To Giz
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18752}) then
		e.self:Say("You wanna be part of the Ebon Mask, huh? Well, you'll need to impress me. Here's your guild tunic. Seek out the other masters, they'll have some work for you, I'm sure. Don't screw up, kid. That pretty face of yours would make a fine trophy, got it? Now, quit breathin' my air, and go get some work done.")
		e.other:SummonItem(13581)
		e.other:AddEXP(100)
		e.other:Faction(244, 100, 0)
		e.other:Faction(262, -5, 0)
		e.other:Faction(320, -25, 0)
		e.other:Faction(263, -10, 0)
		e.other:Faction(329, -25, 0)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 13891}) then -- Locked Chest / Ebon Mask Shipment
		e.self:Say("So the Freeport take survived after all. You did well, " .. e.other:GetName() .. ". The house rewards those who know how to keep their hands on what belongs to us.")
		e.other:SummonItem(1051) -- Rat Pelt Cape
		e.other:AddEXP(200)
		e.other:GiveCash(0, 0, 5, 0)
		e.other:Faction(244, 10, 0) -- Ebon Mask
		e.other:Faction(262, -5, 0) -- Guards of Qeynos
		e.other:Faction(320, -5, 0) -- Wolves of the North
		e.other:Faction(263, -5, 0) -- Guardians of the Vale
		e.other:Faction(329, -5, 0) -- Carson McCabe
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
