-- Source: akanon/Iony_Gredlong.lua
-- P99 audit: Guild Summons - Abbey of Deep Musing Cleric
-- items: 18775, 13517

function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if e.other:HasItem(18775) then
		e.other:Message(MT.Yellow,"Iony Gredlong's tiny voice echoes throughout the room. 'Welcome to the Abbey of Deep Musing " .. e.other:GetName() .. ". I am Iony Gredlong, your new Guild Master should you accept the ways of the Clerics of the Deep Muses. Read the note in your inventory and then hand it to me when you are ready to begin your training.'");
	end
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("It is very nice to meet you " .. e.other:GetName() .. ". I am Iony Gredlong Priestess of the Underfoot. I coordinate all the training for new clerics here in the Deep Musing.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 18775})) then
		e.self:Say("Welcome to the Abbey of Deep Musing. Here you can train and raise your abilities to the peak of perfection.  Take this tunic and wear it with pride.");
		e.other:SummonItem(13517); -- Worn Felt Tunic*
		e.other:Ding();
		e.other:Faction(240,100,0); -- Deep Muses
		e.other:Faction(288,15,0); -- Merchants of Ak'Anon
		e.other:Faction(255,15,0); -- Gem Choppers
		e.other:Faction(238,-15,0); -- Dark Reflection
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
