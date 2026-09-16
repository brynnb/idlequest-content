-- Source: qeynos/Kinloc_Flamepaw.lua
-- P99 audit: Guild Summons - Hall of Sorcery Magician
-- items: 18719, 13508
function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Greetings, " .. e.other:GetName() .. ". I am Kinloc Flamepaw, Arch Magician of the Order of Three.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 18719})) then
		e.self:Say("Welcome to the Order of Three. I am Kinloc, guildmaster of the magicians. This tunic of the order is for you, wear it with honor. Study hard and master your skills, and you will become an important part of our order. Yestura shall help introduce you to the ways of magic.");
		e.other:SummonItem(13508);
		e.other:Ding();
		e.other:Faction(342, 100, 0);
		e.other:Faction(221, -25, 0);
		e.other:Faction(262, 15, 0);
		e.other:Faction(296, -15, 0);
		e.other:AddEXP(100);
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
