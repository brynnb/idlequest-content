-- Source: freportn/Caskin_Marsheart.lua
-- items: 18747, 13571
function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if(e.other:HasItem(18747)) then
		e.other:Message(MT.Yellow,"As you get your bearings, you can hear a beautiful song. It almost seems to draw you towards it. It's as if you can hear a voice in your head as the music surrounds you. 'Welcome to Marsheart's Chords. young bard. I am Caskin Marsheart. To begin your training as a bard, read the note in your inventory and hand it to me.' The music then fades as quickly as it had begun.");
	end
end

function event_say(e)
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 18747})) then
		e.self:Say("Welcome to the guild. here's your guild tunic. Now. let's get to work.");
		e.other:SummonItem(13571); -- Item: Colorfully Patched Tunic*
		e.other:Ding();
		e.other:Faction(284,100,0); -- Faction: League of Antonican Bards
		e.other:Faction(281,15,0); -- Faction: Knights of Truth
		e.other:Faction(262,15,0); -- Faction: Guards of Qeynos
		e.other:Faction(304,-5,0); -- Faction: Ring of Scale
		e.other:Faction(285,-5,0); -- Faction: Mayong Mistmoore
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade);
end

-- END of FILE Zone:freportn  -- Caskin_Marsheart
