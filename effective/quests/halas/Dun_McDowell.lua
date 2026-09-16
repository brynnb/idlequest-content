-- Source: halas/Dun_McDowell.lua
-- items: 18762, 13513
function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if(e.other:HasItem(18762)) then
		e.other:Message(MT.Yellow,"Dun McDowell turns to address you. 'Welcome. I trust ye are ready for training in the ways of the rogue? Well read the note in your inventory and hand it to me when ye are ready to begin training.'");
	end
end

function event_say(e)
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 18762})) then
		e.self:Say("Ah.. ye wish to be a member o' the White Rose, then. eh? Well, let's train ye fer a bit. and see if ye've got what it takes.");
		e.other:Ding();
		e.other:SummonItem(13513);	-- torn white tunic
		e.other:Faction(305,100); 	-- Rogues of the White Rose
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

-- END of FILE Zone:halas  ID:29069 -- Dun_McDowell 
