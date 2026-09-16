-- Source: freeporteast/Venox_Tarkog.lua
-- P99 audit: Guild Summons - Dismal Rage Cleric
-- items: 18744, 13561
function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Welcome to the shrine of the Dismal Rage.  May [Innoruuk] guide your every move in life.  Here. we will teach you to release your rage unto the world.  My priests are at your disposal.");
	elseif(e.message:findi("innoruuk")) then
		e.self:Say("You do not even know the name of the Prince of Hate! That is a crime in here. Our god Innoruuk speaks with Pietro Zarn himself. It was Innoruuk who told him to create the Dismal Rage. You should speak with our family. Perhaps someone will help you better understand our beliefs.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 18744})) then
		e.self:Say("Here we find a new follower. Here we find a tunic of the Dismal Rage. Put the two together and let the hate grow. Let it be known from now on that your soul belongs to the Prince of Hate, Innoruuk. It is his power which flows within you. Destroy all those who oppose us.");
		e.other:SummonItem(13561);
		e.other:Ding();
		e.other:Faction(271, 100, 0);
		e.other:Faction(281, -15, 0);
		e.other:Faction(296, 20, 0);
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
