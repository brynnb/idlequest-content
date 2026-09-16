-- Source: akanon/Welno_Tanlonikan.lua
-- P99 audit: Guild Summons - Abbey of Deep Musing Rogue
-- P99 identifies this NPC as Welno Tanboots; the local spawn/NPC row is Welno Tanlonikan at the same guild location.
-- items: 18776, 13519
function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if e.other:HasItem(18776) then
		e.other:Message(MT.Yellow,"A voice echoes throughout the room as you take in your surroundings. 'Hey you! This is Welno Tanlonikan. Remember me? Read the note in your inventory and then hand it to me. Hurry up! We don't have all day! You owe me a lot of money!'");
	end
end

function event_say(e)
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 18776})) then -- Note
		e.self:Say("Yes, I just knew you'd see it my way, " .. e.other:GetName() .. ". Anyway, welcome to our little part of Ak'Anon's underworld. We have to pay a high price to keep our small organization hidden, which keeps us all busy around here.");
		e.other:SummonItem(13519);	-- Scuffed Tunic*
		e.other:Ding();
		e.other:Faction(240,100); 	-- Deep Muses
		e.other:Faction(288,15); 	-- Merchants of Ak'Anon
		e.other:Faction(255,15); 	-- Gem Choppers
		e.other:Faction(238,-15); 	-- Dark Reflection
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
