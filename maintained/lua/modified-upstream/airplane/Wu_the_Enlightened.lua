-- Source: airplane/Wu_the_Enlightened.lua
-- Monk Plane of Sky tests: current P99 page names Wu's Fist of Mastery for Test of Fists.
-- items: 20800, 20954, 20799, 1283, 20803, 20801, 20802, 20960, 27715, 20967, 20804, 20805, 11698

function event_spawn(e)
	eq.set_timer("depop",300000);
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Greetings Warrior of mind and body. To prove your worth to me, you must complete a test. Which test do you wish to take? I will permit you to take the test of tears, fists, or tranquility.");
	elseif(e.message:findi("tears")) then
		e.self:Say("The test of tears involves knowing when to release, and when to provide a shoulder for another. Bring me a spiroc statuette, a spiroc talon, and a silken wrap. I will teach you the way.");
	elseif(e.message:findi("fists")) then
		e.self:Say("A monk must know when to use his or her fists, and when to use the mind. In this endeavor, you must decide which you shall use. Return to me, once you have found them, a pair of brass knuckles, a white spiroc feather, an ethereal amethyst, and a nebulous sapphire.");
	elseif(e.message:findi("tranquility")) then
		e.self:Say("Ah, the test of tranquility. Only the tranquil monk can achieve enlightenment. Are you such an individual? Time shall tell. Retrieve these items for me. Bring an aged nectar, a Writ or Decree of Quellious, and a Tear of Quellious. Then we shall assess your ability.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 20800, item2 = 20954, item3 = 20799})) then
		e.other:SummonItem(1283); -- Ton Po's Shoulder Wraps
		e.other:AddEXP(100000);
		e.self:Say("You have moved closer to enlightenment.");
		eq.depop();
	elseif(item_lib.check_turn_in(e.trade, {item1 = 20803, item2 = 20801, item3 = 20802, item4 = 20960})) then
		e.other:SummonItem(27715); -- Wu's Fist of Mastery
		e.other:AddEXP(100000);
		e.self:Say("You have moved closer to enlightenment.");
		eq.depop();
	elseif(item_lib.check_turn_in(e.trade, {item1 = 20967, item2 = 20804, item3 = 20805})) then
		e.other:SummonItem(11698); -- Golden Sash of Tranquility
		e.other:AddEXP(100000);
		e.self:Say("You have moved closer to enlightenment.");
		eq.depop();
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_timer(e)
	eq.stop_timer("depop");
	eq.depop();
end

