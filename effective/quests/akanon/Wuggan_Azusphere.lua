-- Source: akanon/Wuggan_Azusphere.lua
-- items: 18772, 13522
function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if e.other:HasItem(18772) then
		e.other:Message(MT.Yellow,"An older, male gnome stands before you. 'Welcome young apprentice to the Library Mechanimagica. I am Wuggan Azusphere. Read the note in your inventory and then hand it to me so that we can begin your training.'");
	end
end

function event_say(e)
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 18772})) then -- Registration Letter
		e.self:Say("Welcome to Library Mechanimagica. I am Master Magician Wuggan Azusphere, and I will help to teach you the ways of summoning. Here is our guild tunic, make us proud.");
		e.other:SummonItem(13522);	-- Dirty Gold Felt Robe*
		e.other:Ding();
		e.other:Faction(245,100,0); 	-- eldritch collective
		e.other:Faction(238,-15,0); 	-- Dark reflection
		e.other:Faction(239,-5,0);	-- the dead
		e.other:Faction(255,15,0); 	-- gem choppers
		e.other:Faction(333,15,0); 	-- king ak'anon
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
