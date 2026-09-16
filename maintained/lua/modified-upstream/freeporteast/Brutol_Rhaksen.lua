-- Source: freeporteast/Brutol_Rhaksen.lua
-- P99 audit: Guild Summons - Dismal Rage Warrior
-- items: 18857, 13561
function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Oh. hello down there. puny one. I'm Brutol Rhaksen. Commander of warriors who serve the Dismal Rage.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 18857})) then
		e.self:Say("Welcome to warriors guild of East Freeport. Take this to help you on your journeys.");
		e.other:SummonItem(13561);
		e.other:Ding();
		e.other:Faction(271, 100, 0);
		e.other:Faction(281, -15, 0);
		e.other:Faction(296, 20, 0);
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
