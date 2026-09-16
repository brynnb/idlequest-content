-- Source: freporte/Heneva_Jexsped.lua
-- P99 audit: Guild Summons - Dismal Rage Magician
-- items: 18855, 13565
function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Yes. yes. yes. Hail to you, too, " .. e.other:GetName() .. ". Now, quit bugging me!");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 18855})) then
		e.self:Say("Welcome, friend. I see more than a slight glimmer of hate in your eyes. Good, for we have much work to do.");
		e.other:SummonItem(13565);
		e.other:Ding();
		e.other:Faction(271, 100, 0);
		e.other:Faction(281, -15, 0);
		e.other:Faction(296, 20, 0);
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
