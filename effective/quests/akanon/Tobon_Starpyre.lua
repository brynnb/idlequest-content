-- Source: akanon/Tobon_Starpyre.lua
-- items: 18868, 18774, 13522, 13275, 13276, 13277, 13279, 15380, 15477, 15656
function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if e.other:HasItem(18774) then
		e.other:Message(MT.Yellow,"A wise looking gnome stands before you. 'Welcome to the Library Mechanimagica young apprentice. I am Tobon Starpyre. Read the note in your inventory and give it to me so that we may begin your training'");
	end
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("It is good to see the young show an interest in the ways of magic. Its circles can be used in tandem with our unique ways of tinkering. Have you [joined the Eldritch Collective] or are you [merely curious]?");
	elseif(e.message:findi("joined the Eldritch Collective")) then
		e.self:Say("Very good. Would you like to [go on a little mission] or are you busy studying?");
	elseif(e.message:findi("merely curious")) then
		e.self:Say("Please look around. We have much knowledge within these halls. May you soon find your place among our members. Good day.");
	elseif(e.message:findi("go on a little mission")) then
		e.self:Say("Fabulous! Here is a list of the observers outside of Ak'Anon. Go and ask each for a [spare telescope lens]. Each should give you one. We have need of them. I await your return as does your reward, either Fire Bolt or Fingers of Fire. Meant for a skilled wizard of the eighth trial.");
		e.other:SummonItem(18868); 	-- Observer List
		e.other:Ding();
	elseif(e.message:findi("yendar")) then
		e.self:Say("Oh, he is my older brother. Used to be the leader of the Eldritch Collective. Then he founded the Observers, a pretty good piece of work. Went off his rocker a long while back, though. Became obsessed with Innoruuk and the Teir'Dal. Stays away for days at a time, nobody knows where he has been. Mother still worries about him, asked me to keep an eye on him. But he is a grown gnome, and with his mastery of the art, has little to fear in this world or others. But if you are seeking him, I would look outside Ak'Anon, in the Steamfonts. That is where he makes his home these days.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 18774})) then -- Registration Letter
		e.self:Say("Ah.. Welcome, friend! I am Tobon Starpyre, Master Wizard of Library Mechanimagica. This is our tunic - wear it with pride. Study hard, master your skills, and make us proud.");
		e.other:SummonItem(13522);	-- Dirty Gold Felt Robe*
		e.other:Faction(245,100,0); 	-- eldritch collective
		e.other:Faction(238,-15,0); 	-- Dark reflection
		e.other:Faction(239,-5,0);	-- the dead
		e.other:Faction(255,15,0); 	-- gem choppers
		e.other:Faction(333,15,0); 	-- king ak'anon
		e.other:Faction(288,15,0); 	-- Merchants of Ak'Anon
		e.other:Ding();
		e.other:AddEXP(100);
	elseif(item_lib.check_turn_in(e.trade, {item1 = 13275, item2 = 13276, item3 = 13277, item4 = 13279})) then
		e.self:Say("Thank you for your work. I heard news of the troubles you encountered. Besides these troubles you still completed your mission. We are grateful. And as I once stated, your reward awaits.");
		e.other:SummonItem(eq.ChooseRandom(15380,15477,15656)); -- Item(s): Spell: Column of Frost (15380), Spell: Fire Bolt (15477), Spell: Shock of Ice (15656)
		e.other:Faction(245,10,0); -- Eldritch Collective
		e.other:Faction(238,-10,0); -- Dark Reflection
		e.other:Faction(239,-10,0); -- The Dead
		e.other:Faction(255,10,0); -- Gem Choppers
		e.other:Faction(333,10,0); -- King Ak'Anon
		e.other:Ding();
		e.other:AddEXP(500);
		e.other:GiveCash(0,0,0,1);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
