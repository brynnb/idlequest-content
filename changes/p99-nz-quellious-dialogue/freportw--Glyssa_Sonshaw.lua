-- Source: ProjectEQ freportw/Glyssa_Sonshaw.lua; Quellious Symbol Quests
-- P99 preserved page: quellious-symbol-quests-56786fa4e0.wiki
-- Corrected documented faction amounts; retained upstream XP where unspecified.
-- items: 1772, 14585, 1779
function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 1772, item2 = 14585})) then
		e.self:Say("Ah..yes, I have seen this symbol before. There is a kobold that lives among the gnomes of Ak'anon. He may be reluctant to speak with you but you have no need to fear him. He is a follower of Brell Serilis and a valuable source of information on kobold society and culture. I will construct a message for him. Deliver the message and necklace and perhaps he can enlighten you to its meaning.");
		e.other:SummonItem(14585);
		e.other:SummonItem(1779);
		e.other:Ding();
		e.other:Faction(220,10,0);
		e.other:Faction(281,2,0);
		e.other:Faction(296,-1,0);
		e.other:Faction(330,-1,0);
		e.other:AddEXP(1000);
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
