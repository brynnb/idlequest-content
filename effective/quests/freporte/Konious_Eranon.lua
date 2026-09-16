-- Source: freporte/Konious_Eranon.lua
-- P99 audit: Guild Summons - Dismal Rage Enchanter
-- items: 18856, 13565
function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Greetings!  I am the mighty Konious Eranon, Master Enchanter, devoted follower of Innoruuk, and loyal assistant to the all-powerful Nexvok.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 18856})) then
		e.self:Say("Hey, Nex, we got another sucker.. Er.. Volunteer, that is, to help us out around here. Here ya go friend, put this on and let's whip you into shape.");
		e.other:SummonItem(13565);
		e.other:Ding();
		e.other:Faction(271, 100, 0);
		e.other:Faction(281, -15, 0);
		e.other:Faction(296, 20, 0);
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
