-- Source: airplane/Relinin_Skyrunner.lua
-- P99 audit: Ranger Plane of Sky Tests
-- items: 20934, 20850, 20849, 14567, 20853, 20852, 20851, 27731, 20854, 20948, 20855, 2714

function event_spawn(e)
	eq.set_timer("depop",300000);
end

function event_say(e)
	if e.message:findi("trade") then
		e.self:Say("I am currently interested in trading for a Spiroc Healer's Cloak. I will even trade something of a better value for it.");
		return;
	end
	if(e.message:findi("hail")) then
		e.self:Say("Greetings " .. e.other:GetName() .. ". I can only assume my reason for being summoned is that you wish to take the tests. Would you like to be tested in the body, in defense, or in the element of earth? Or would you like to [trade]?");
	end
	if(e.message:findi("body")) then
		e.self:Say("Very well. You must scour this plane and bring back to me these components: an auburn tessera, a ysgaril root, and a griffon talon. Make haste, and good luck.");
	end
	if(e.message:findi("defense")) then
		e.self:Say("Defense it is. You must prove yourself worthy enough for the spiroc spirits to guard you. Bring back to me a mithril disc, a harpy tongue, and a fine velvet cloak. Good luck to you.");
	end
	if(e.message:findi("element of earth")) then
		e.self:Say("Elemental earth you say? When adeptly controlled, the elements can be among our best allies. Retrieve a gridelin globe, a dragon hide mantle, and a spiroc earth totem. Only with these items can you master the element of earth.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 20934, item2 = 20850, item3 = 20849})) then
		e.other:SummonItem(14567); -- Item: Griffon Talon Necklace
		e.other:AddEXP(100000);
		e.self:Say("Good work, ranger.");
		eq.depop();
	elseif(item_lib.check_turn_in(e.trade, {item1 = 20853, item2 = 20852, item3 = 20851})) then
		e.other:SummonItem(27731); -- Item: Dark Cloak of the Sky
		e.other:AddEXP(100000);
		e.self:Say("Good work, ranger.");
		eq.depop();
	elseif(item_lib.check_turn_in(e.trade, {item1 = 20854, item2 = 20948, item3 = 20855})) then
		e.other:SummonItem(2714); -- Item: Earthshaker's Mantle
		e.other:AddEXP(100000);
		e.self:Say("Good work, ranger.");
		eq.depop();
	elseif item_lib.check_turn_in(e.trade, {item1 = 2715}) then
		e.other:SummonItem(27731); -- Documented old Sky reward upgrade.

	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_timer(e)
	if e.timer == "depop" then
	eq.stop_timer("depop");
	eq.depop();
	end
end
