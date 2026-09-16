-- Source: qeynos/Ebon_Strongbear.lua
-- P99 audit: Guild Summons - Hall of Steel
-- items: 18707, 13504
function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Welcome. I am the champion of the Steel Warriors. There are none who can challenge me. I guide this brotherhood of Steel Warriors. From Qeynos to the trade city of Freeport, the ways of the Steel Warriors are taught. I welcome all young Steel Warriors.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 18707})) then
		e.self:Say("So then, you wish to join the ranks of the Steel Warriors? Very good, then - take this tunic and wear it with pride. Visit our arena trainers to make preparations for battle and then take your weapon to the field! Remember in all that you do, you represent the Steel Warriors in thought and deed!");
		e.other:SummonItem(13504);
		e.other:Ding();
		e.other:Faction(311, 100, 0);
		e.other:Faction(262, 15, 0);
		e.other:Faction(230, -15, 0);
		e.other:Faction(330, -15, 0);
		e.other:Faction(281, 15, 0);
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
