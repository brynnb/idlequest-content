-- Source: akanon/Rilgor_Plegnog.lua
-- items: 18703, 13524, 1360, 10600
function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if e.other:HasItem(18703) then
		e.other:Message(MT.Yellow,"An evil cackle echoes throughout the mines as you get your bearings. Rilgor Plegnog turns his gaze upon you. 'Why do you stand about young apprentice?! There is much to learn. Read the note in your inventory and then hand it to me so that we can begin your training! The Dark Reflection will have its revenge!'");
	end
end

function event_say(e)
	if (e.message:findi("mechanical pen")) then
		e.self:Say("Why do you want one of those contraptions. You will spend more time repairing it then you will writing with it. But if you insist on getting one, you are going to have to do a small favor.");
		e.self:Emote("tugs at your robe and grins evilly. 'Mighty nice outfit you have there. Sure beats these drab robes us three are wearing. Hmm...my favorite color is purple, in fact a shiny metallic purple would do nicely. How bad did you want that pen?'");
	elseif(e.message:findi("hail")) then
		e.self:Say("Oh, what is it now. Can't you see that I am a very busy gnome?");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 18703})) then  -- Old Folded Letter
		e.self:Say("Its always good to see new blood eager to learn the dark art of mind control. Please take this robe as a symbolization of loyalty to this house.");
		e.other:Ding();
		e.other:SummonItem(13524);	-- Dark Gold Felt Robe*
		e.other:Faction(238,100,0); 	-- Dark reflection
		e.other:Faction(245,-10,0); 	-- eldritch collective
		e.other:Faction(255,-10,0); -- gem choppers
		e.other:Faction(240,-10,0); 	-- Deepmuses
		e.other:AddEXP(100);
	elseif (item_lib.check_turn_in(e.trade, {item1 = 1360})) then
		e.self:Say("Very nice!! It is perfect! Here take this pen. Have fun with it.");
		e.other:Ding();
		e.other:AddEXP(50000);
		e.other:SummonItem(10600); -- Item: Mechanical Pen
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
