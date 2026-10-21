-- Source: freeportwest/Opal_Darkbriar.lua
-- items: 18739, 13558
function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if e.other:HasItem(18739) then
		e.other:Message(MT.Yellow,"As you make your way into a small dimly lit room, a robed figure turns to greet you. 'Hello there. friend. I am Opal Darkbriar, Wizard Guild Master. Should you wish to begin your training, read the note in your inventory and then hand it to me.'");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 18739})) then -- A tattered not
		e.self:Say("Welcome to the Academy of Arcane Sciences. Here's one of our guild robes for you to wear. Once you are ready to begin your training please make sure that you see Shana Liskia, he can assist you in developing your hunting and gathering skills.");
		e.other:SummonItem(13558); -- Patched Violet Robe
		e.other:Ding();
		e.other:Faction(220,100,0); -- Arcane Scientists
		e.other:Faction(281,25,0); -- Knights of Truth
		e.other:Faction(296,-15,0); -- Opal Dark Briar
		e.other:Faction(330,-15,0); -- The Freeport Militia
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

-- END of FILE Zone:freeportwest -- Opal_Darkbriar
