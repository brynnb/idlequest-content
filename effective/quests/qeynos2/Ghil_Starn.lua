-- Modified from ProjectEQ Lua to complete P99 "The Package".
-- P99: https://wiki.project1999.com/The_Package
-- items: 13784, 18796, 1049

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("I'm Ghil.. I used to run a small business before I hooked up with Hanns. Together, we muscled our competition out of Qeynos. But I'm getting too old for the rough stuff anymore, so I just lay low down here and peddle my goods. Anyway, I gotta get back to work and pack up this shipment for ol' [Denny-boy]");
	elseif(e.message:findi("denny")) then
		e.self:Say("Den Magason works for ol' [Captain Rohand] down at the Qeynos docks. I need to find someone to take a [package] to him, so it can be shipped to Erudin.");
	elseif(e.message:findi("captain rohand")) then
		e.self:Say("Captain Rohand runs the Mermaid's Lure and trades goods with the sea merchants from Odus.");
	elseif(e.message:findi("package")) then
		e.self:Say("I need someone to take this package to Den. He'll make sure it goes out on the next ship to Odus. I owe him a small favor, too.. So when you meet up with him, I need you to do whatever you can to help him out. Do a good job.");
		e.other:SummonItem(13784); -- Package for Den
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 18796})) then
		e.self:Say("Good work. Denny-boy says you handled yourself well, and I like people who finish a job. Take these gloves and a little coin for your trouble.");
		e.other:Ding();
		e.other:SummonItem(1049); -- Brown Leather Gloves
		e.other:Faction(223,2,0); -- Circle of Unseen Hands
		e.other:Faction(230,2,0); -- Corrupt Qeynos Guards
		e.other:Faction(273,2,0); -- Kane Bayle
		e.other:Faction(291,-2,0); -- Merchants of Qeynos
		e.other:Faction(262,-2,0); -- Guards of Qeynos
		e.other:AddEXP(200);
		e.other:GiveCash(0,0,5,0);
	end

	item_lib.return_items(e.self, e.other, e.trade)
end
