-- Source: freporte/Nexvok_Thirod.lua
-- P99 audit: Guild Summons - Dismal Rage Wizard
-- items: 18854, 13562
function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("I am Nexvok, master wizard of the Dismal Rage. My associates Heneva and Konious and I provide our services to master Zarn on a regular basis. People of our talent are in high demand. and Pietro pays well, so we are, of course, very loyal.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 18854})) then
		e.self:Say("Thanks");
		e.other:SummonItem(13562);
		e.other:Ding();
		e.other:Faction(271, 100, 0);
		e.other:Faction(281, -15, 0);
		e.other:Faction(296, 20, 0);
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
