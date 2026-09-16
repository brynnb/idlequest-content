-- P99 source: Azraxs' Legacy
-- items: 7114, 7105

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 7114})) then -- Completed Soul Trap
		e.self:Say("Ahhh, sweet release. Wait.. what is this? No! Do not bind me to this filthy bit of leather! Release! Curse you and curse Azrax to damnation!!!");
		e.other:SummonItem(7105); -- Mantle of Souls
		e.other:Faction(265,10,0); -- Heretics
		e.other:Faction(242,-10,0); -- Deepwater Knights
		e.other:Faction(254,-10,0); -- Gate Callers
		e.other:Faction(231,-10,0); -- Craftkeepers
		e.other:Faction(233,-10,0); -- Crimson Hands
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
