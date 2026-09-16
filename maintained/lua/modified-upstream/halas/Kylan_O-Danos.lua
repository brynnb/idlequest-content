-- Source: halas/Kylan_O-Danos.lua
-- items: 18760, 13511
function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if(e.other:HasItem(18760)) then
		e.other:Message(MT.Yellow,"A stern looking Barbarian turns to greet you. 'A new recruit? Well you better get ready for some hard work! I don't tolerate laziness! I am Kylan O`Danos, your new Guild Master. Read the note in your inventory and give it to me when you are ready to begin your training!'");
	end
end

function event_say(e)
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 18760})) then
		e.self:Say("Greetin's! We are the mighty Wolves o' the North, protectors o' Halas, and we must work hard t' keep it safe fer our citizens. Here is our tunic, it identifies ye as a proud warrior o' this great city. Let's get started with yer training, then, shall we?");
		e.other:Ding();
		e.other:SummonItem(13511); -- Item: Patched Fur Tunic*
		e.other:Faction(320,100);	-- Wolves of the North
		e.other:Faction(327,20); 	-- Shamen of Justice
		e.other:Faction(328,25);	-- Merchants of Halas
		e.other:Faction(311,5); 	-- Steel Warriors
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

-- END of FILE Zone:halas  ID:29057 -- Kylan_O`Danos
