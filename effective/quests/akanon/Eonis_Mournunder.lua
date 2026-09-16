-- Source: akanon/Eonis_Mournunder.lua
-- items: 18771, 13524
function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if(e.other:HasItem(18771)) then
		e.other:Message(MT.Yellow,"A diminutive, but powerful looking gnome stands before you. 'I am Eonis Mournunder. The Dark Reflection has called you. Read the note in your inventory and hand it to me when you wish to begin your training. Your destiny awaits!'");
	end
end

function event_say(e)
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 18771})) then -- Stained Letter
		e.self:Say("Hmmm.. As you wish, we will train you in our dark ways. But know this: our art carries a high price, and there is no turning back for you now.");
		e.other:SummonItem(13524); 	-- Dark Gold Felt Robe*
		e.other:Ding();
		e.other:Faction(238,100,0); 	-- Dark reflection
		e.other:Faction(245,-10,0); 	-- eldritch collective
		e.other:Faction(255,-10,0); -- gem choppers
		e.other:Faction(240,-10,0); 	-- Deepmuses
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
