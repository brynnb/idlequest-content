-- IdleQuest P99 restoration: The Orc Impaler.
-- P99: https://wiki.project1999.com/The_Orc_Impaler
-- items: 20635, 20640, 20637, 20638

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Speak quickly. The undead ruins are too near, and every shadow has begun to look like a spy.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 20635})) then -- Warning to Glidara
		e.self:Say("So the Ghoul Boss knows of our inquiries? I fear that villain not! In fact, we must find out how much information he has received. Invade the undead ruins nearby and retrieve his log. Take this ring; it will protect you from his spells. Return my ring with his log book and we will hopefully crack the mystery of Kithicor.");
		e.other:SummonItem(20640); -- Glidara's Ring
	elseif(item_lib.check_turn_in(e.trade, {item1 = 20640, item2 = 20637})) then -- Glidara's Ring + Ghoul Boss' Log Book
		e.self:Say("Daring work, " .. e.other:GetName() .. ". I have imprinted my seal on this log so that only Morin may open it. Deliver the log to Morin.");
		e.other:SummonItem(20638); -- Sealed Ghoul Boss' Log Book
	end

	item_lib.return_items(e.self, e.other, e.trade)
end
