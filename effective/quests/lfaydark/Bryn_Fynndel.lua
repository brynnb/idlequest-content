-- IdleQuest P99 restoration: The Orc Impaler.
-- P99: https://wiki.project1999.com/The_Orc_Impaler
-- items: 20636, 20635, 20639, 7330

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Greetings, traveler. These woods are watched closely, for dark powers gather where the trees grow old.");
	elseif(e.message:findi("morin sent me")) then
		e.self:Say("Morin Shadowbane, the great ranger, sent you to assist us? A strong ranger you must be if he has sent you personally. There is a great evil shaking the land, and it has spread its tendrils into Kithicor Forest. We believe the [shadowed men] are involved with this, somehow.");
	elseif(e.message:findi("shadowed men")) then
		e.self:Say("The shadowed men have recently begun to appear with vile purposes unknown to us. Their leader wanders these woods with a contingent of guards. Bring us his code book, and we may learn more of their plans.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 20636})) then -- Shadowed Code Book
		e.self:Say("Excellent work, " .. e.other:GetName() .. "! According to these codes, it seems the Ghoul Boss has been alerted to our probes now that his messenger is missing. We have a scout, Glidara Myllar, that may be in danger. Give her this note as soon as you can, she is in grave danger!");
		e.other:SummonItem(20635); -- Warning to Glidara
		eq.spawn2(57058, 0, 0, 2557, 63, -6.75, 0); -- Glidara_Myllar
	elseif(item_lib.check_turn_in(e.trade, {item1 = 20639})) then -- Orders for Bryn
		e.self:Say("The vile Ghoul Boss has been defeated! My new orders state to arm you with our finest weaponry. Take this, the mighty Orc Impaler. Safe journeys, brave adventurer.");
		e.other:Ding();
		e.other:SummonItem(7330); -- Orc Impaler
		e.other:AddEXP(200);
	end

	item_lib.return_items(e.self, e.other, e.trade)
end
