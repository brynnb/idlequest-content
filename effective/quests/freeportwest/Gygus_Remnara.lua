-- Source: freeportwest/Gygus_Remnara.lua
-- P99 audit: Guild Summons - Temple of Marr Paladin
-- items: 18738, 13554
function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if(e.other:HasItem(18738)) then
		e.other:Message(MT.Yellow,"As you bask in the majesty of the Temple of Marr, an important looking individual, clad in shining metal armor turns to greet you. 'I can spot a new recruit a mile away. Welcome to the Temple of Marr. I am Gygus Remnara. Read the note in your inventory and hand it to me to begin your training. I wish you the best of luck.'");
	end
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("The Temple of Marr welcomes you. I am Gygus Remnara. High Sentinel for the Sentries of Passion. We are the order of paladins within the Priests of Marr and whose charge it is to protect the holy Temple of Marr.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 18738})) then -- Tattered Note
		e.self:Say("Welcome to the Sentries of Passion. We are the protectors of the Temple of Marr. Wear our tunic with pride, young knight! Find your wisdom within these walls and in the words of our priests. And remember to aid all who follow the twin deities, Mithaniel and Erollisi Marr.");
		e.other:SummonItem(13554); -- Faded Purple Tunic*
		e.other:Ding();
		e.other:Faction(362,100,0); -- Priests of Marr
		e.other:Faction(330,-10,0); -- Freeport Militia
		e.other:Faction(281,15,0); -- Knights of Truth
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade);
end

-- END of FILE Zone:freeportwest  ID:8028 -- Gygus_Remnara
