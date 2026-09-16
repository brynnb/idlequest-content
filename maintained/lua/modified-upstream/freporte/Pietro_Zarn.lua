-- Source: freporte/Pietro_Zarn.lua
-- P99 audit: Guild Summons - Dismal Rage Shadowknight
-- items: 18743, 13561, 18961, 12153
function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Who are you that you dare to speak with the great Pietro Zarn!! I see nothing more than a whelp in front of me. Innoruuk himself speaks with me. And now you expect me to waste words on you, a commoner. Begone " .. e.other:GetName() .. ". You have nothing to peak my interest, only my rage.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 18743})) then
		e.self:Say("A new member to carry the rage of Innoruuk into the city and beyond. How wonderful. I must admit that you do not appear to carry the rage within. Hopefully you shall color the battlefields with the blood of many knights from the Hall of Truth. Here. Wear this tunic with pride. Ha ha ha!! We shall see young one. We shall see.");
		e.other:SummonItem(13561);
		e.other:Ding();
		e.other:Faction(271, 100, 0);
		e.other:Faction(281, -15, 0);
		e.other:Faction(296, 20, 0);
		e.other:AddEXP(100);
	elseif(item_lib.check_turn_in(e.trade, {item1 = 18961})) then
		e.self:Say("I will deal with this " .. e.other:GetName() .. ". Take this and know that you are welcomed by the Dismal Rage.");
		e.other:SummonItem(12153);
		e.other:Ding();
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
