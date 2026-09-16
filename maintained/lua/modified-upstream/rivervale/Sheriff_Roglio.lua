-- Source: rivervale/Sheriff_Roglio.lua
-- items: 18733, 13540, 13931, 13023, 13024
function event_spawn(e)
	local xloc = e.self:GetX();
	local yloc = e.self:GetY();
	eq.set_proximity(xloc - 50, xloc + 50, yloc - 50, yloc + 50);
end

function event_enter(e)
	if(e.other:HasItem(18733)) then
		e.other:Message(MT.Yellow,"As your eyes adjust to the interior of your surroundings, you see Mayor Gubbin and Sheriff Roglio standing nearby. The Mayor turns towards Sheriff Roglio. 'Looks like we have another fine young recruit to join your ranks, Roglio!' Sheriff Roglio looks your way. 'Greetings, recruit. Read the note in your inventory and hand it to me when you wish to start your training.'");
	end
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Hail, " .. e.other:GetName() .. "! Stand tall whenever you are speaking to the Sheriff of Rivervale. I command the warriors of this vale. You must be new to the ranks of the Guardians of the Vale, so be sure to report to your squad at once. We must protect our people. The [danger] has come closer to home. If you are not a deputy, then please leave these halls.");
	elseif(e.message:findi("danger")) then
		e.self:Say("What danger?!! You must be new to the community. The goblins of Clan Runnyeye have been scaling our wall somehow. You must join our forces in exterminating every one of those beasts. Your wages are earned with every four bloody goblin warbead necklaces you return to me. Now be off and fight the good fight.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 18733})) then -- Hand in Warrior Recuitment Letter
		e.self:Say("Welcome to the Guardians of the Vale. I'm Roglio Bruth, and I run this proud little outfit. You seem to be of hearty stock, let's put you to work. Here's your guild tunic - hope it fits. Start your training right away. Once you are ready to begin please make sure that you see Dalario Blistbobble, he can assist you in developing your hunting and gathering skills.");
		e.other:SummonItem(13540); -- Old Tan Tunic
		e.other:Ding();
		e.other:Faction(263, 100,0); -- Gaurdians of the Vale
		e.other:Faction(286, 15,0); -- Mayor Gubbin
		e.other:Faction(355, 10,0); -- Storm Reapers
		e.other:Faction(292, 15,0); -- Merchants of Rivervale
		e.other:Faction(334,-15,0); -- Dreadguard Outer
		e.other:AddEXP(100);
	elseif(item_lib.check_turn_in(e.trade, {item1 = 13931,item2 = 13931,item3 = 13931,item4 = 13931})) then -- Hand in Runnyeye Warbeads
		if e.other:GetFaction(e.self) > 4 then
			e.self:Say("If you are not a deputy, then please leave these halls.");
			e.other:SummonItem(13931);
			e.other:SummonItem(13931);
			e.other:SummonItem(13931);
			e.other:SummonItem(13931);
		else
			e.self:Say("Good work, Deputy " .. e.other:GetName() .. "! We shall soon rid our countryside of the goblin threat. Here are your wages. Eat well tonight!");
			e.other:SummonItem(13023); -- Bixie Berry Buns
			e.other:SummonItem(13024); -- Tanglefoot Tingle Drink
			e.other:Ding();
			e.other:Faction(263, 1,0); -- Gaurdians of the Vale
			e.other:Faction(286, 1,0); -- Mayor Gubbin
			e.other:Faction(355, 1,0); -- Storm Reapers
			e.other:Faction(292, 1,0); -- Merchants of Rivervale
			e.other:Faction(334,-1,0); -- Dreadguard Outer
			e.other:AddEXP(6400);
			e.other:GiveCash(0,8,0,0);
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

-- End of File, Zone:rivervale  NPC:19058 -- Sheriff_Roglio
