-- Source: qeynos/Renic_Losaren.lua
-- items: 18715, 13505
function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if e.other:HasItem(18715) then
		e.other:Message(MT.Yellow,"As you glance about the room, Renic Losaren greets you. 'Why hello there. Are you perhaps a new recruit? If you wish to follow the ways of Karana and become a cleric, read the note in your inventory and hand me your note to start your training.'");
	end
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say(string.format("Welcome, %s.  Please feel at ease here in the Temple of Thunder.  We, the Knights of Thunder, are here to guide and serve.",e.other:GetName()));
	end
end

function event_trade(e)
	local item_lib =require("items");
	
	if(item_lib.check_turn_in(e.trade, {item1 = 18715})) then -- Tattered Note
		e.self:Say("Welcome, friend, to the Temple of Thunder. Here, you can practice your skills and learn the ways of Karana. Take this tunic and wear it with pride, for you are now a Priest of Thunder.");
		e.other:SummonItem(13505); -- Old Gray Tunic*
		e.other:Ding();
		e.other:Faction(280,100,0); -- Knight of Thunder
		e.other:Faction(221,-100,0); -- Bloodsabers
		e.other:Faction(341,75,0); -- Priest of Life
		e.other:Faction(262,75,0); -- Guards of Qeynos
		e.other:AddEXP(100);
	end
	
	item_lib.return_items(e.self, e.other, e.trade)
end
