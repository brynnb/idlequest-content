-- Source: akanon/Vaenor_Husga.lua
-- items: 18702, 13524
function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if e.other:HasItem(18702) then
		e.other:Message(MT.Yellow,"An evil cackle echoes throughout the mines as you get your bearings. Vaenor Husga turns his gaze upon you. 'Why do you stand about young apprentice?! There is much to learn. Read the note in your inventory and then hand it to me so that we can begin your training! The Dark Reflection will have its revenge!'");
	end
end

function event_say(e)
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 18702})) then
		e.self:Say("A new initiate I see. Take this robe you will surely need it in the winter months.");
		e.other:SummonItem(13524);	-- Dark Gold Felt Robe*
		e.other:Faction(238,100,0); 	-- Dark reflection
		e.other:Faction(245,-10,0); 	-- eldritch collective
		e.other:Faction(255,-10,0); -- gem choppers
		e.other:Faction(240,-10,0); 	-- Deepmuses
		e.other:Ding();
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
