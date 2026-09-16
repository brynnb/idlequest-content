-- Source: akanon/Kaxon_Frennor.lua
-- P99 audit: Guild Summons - Dark Reflection Rogue
-- items: 18705, 13518
function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if e.other:HasItem(18705) then
		e.other:Message(MT.Yellow,"A diminutive, but powerful looking gnome stands before you. 'I am Kaxon Frennor. The Dark Reflection has called you. Read the note in your inventory and hand it to me when you wish to begin your training. Your destiny awaits!'");
	end
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Hail " .. e.other:GetName() .. ". I am Kaxon Frennor, master assassin of the Dark Reflection.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if (item_lib.check_turn_in(e.trade, {item1 = 18705})) then -- Old Folded Letter
		e.self:Say("Yes, I just knew you'd see it my way, " .. e.other:GetName() .. ". Anyway, welcome to our little part of Ak'Anon's underworld. We have to pay a high price to keep our small organization hidden, which keeps us all busy around here.");
		e.other:SummonItem(13518); 	-- Tin Patched Tunic*
		e.other:Ding();
		e.other:Faction(238,100,0); 	-- Dark reflection
		e.other:Faction(245,-10,0); 	-- eldritch collective
		e.other:Faction(255,-10,0); -- gem choppers
		e.other:Faction(240,-10,0); 	-- Deepmuses
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
