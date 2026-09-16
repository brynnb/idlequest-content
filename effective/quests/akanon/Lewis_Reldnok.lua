-- Source: akanon/Lewis_Reldnok.lua
-- items: 18433, 13517

function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if e.other:HasItem(18433) then
		e.other:Message(MT.Yellow,"An older, male gnome addresses you as you attempt to get your bearings. 'Welcome young apprentice to the Abbey of Deep Musings. I am Lewis Reldnok. Read the note in your inventory and hand it to me when you wish to begin your training.'");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if item_lib.check_turn_in(e.trade, {item1 = 18433}) then -- Gnome Paladin Note
		e.self:Say("Welcome to the Abbey of Deep Musing, " .. e.other:GetName() .. "! Here is a tunic that you may wear to announce the beginning of your training as a Paladin of Brell Serilis! Be warned that the only dangers do not lie without Ak'Anon. There is an evil society that lurks in the deepest recesses and shadows of our magnificent city. When you are ready to begin your training, let me know.");
		e.other:SummonItem(13517); 	-- worn felt tunic
		e.other:Ding();
		e.other:Faction(240,100,0); 	-- Deep Muses
		e.other:Faction(288,15,0); 	-- Merchants of Ak'Anon
		e.other:Faction(255,15,0); 	-- Gem Choppers
		e.other:Faction(238,-15,0); 	-- Dark Reflection
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
