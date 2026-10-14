-- Source: rivervale/Lendel_Deeppockets.lua
-- items: 18732, 13539
function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if(e.other:HasItem(18732)) then
		e.other:Message(MT.Yellow,"As you get your bearings, you see that you are inside the Fool's Gold, the best place in all of Rivervale to have a drink and relax. Before you can reflect on relaxing however, a serious looking Halfling looks your way. 'Hey you! No loitering. What's that you say! You wish to become a Rogue? Well, you are in the right place. I am Lendel. Read the note in your inventory and when you are ready to start your training, hand me your note.'");
	end
end

-- P99 retains the guild note and Stanos story. Slickfinger armor and rogue
-- epic 1.5 are later additions; do not advertise or consume their ingredients.
function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Its nice to meet you " .. e.other:GetName() .. ". Allow me to introduce myself. I am Lendel Deeppockets master Assassin of Rivervale.")
	end
end

function event_trade(e)
	local item_lib = require("items");
	
	if(item_lib.check_turn_in(e.trade, {item1 = 18732})) then -- Tattered Note
		e.self:Say("HA! I asked that fool Denry to send me a professional, and this is what I get?!? Oh diddlepicks! That crotchety old coot never liked me anyway. And after all I've done for him! Hrrmf! Ah well, let's get you started and see what ya got, huh, kid? Here, wear this. Maybe I'll have Toelia break you in, huh? Yeah, that'll work! Go find her, and she'll put you to work. Just remember, we all earn our keep around here, or else it's back to hay farm for you! Oh yeah, tell her you're the [new dishwasher] so she knows you are on the level.");
		e.other:SummonItem(13539); -- Old Brown Vest*
		e.other:Ding();
		e.other:Faction(241,100,0); -- Deeppockets
		e.other:Faction(223,5,0); -- Circle of Unseen Hands
		e.other:Faction(292,-5,0); -- Merchants of Rivervale
		e.other:Faction(336,5,0); -- Coalition of Tradefolk Underground
		e.other:Faction(329,5,0); -- Carson McCabe
		e.other:AddEXP(100);

	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_signal(e)
	e.self:Say("Find somebody to go see what he wants. I don't like the idea of making Hanns mad at us, but I also don't like the idea of looking over my shoulder for Stanos. He is not somebody I would care to dance with, and I DO owe him.");
end

-- END of FILE Zone:rivervale  ID:19066 -- Lendel_Deeppockets
