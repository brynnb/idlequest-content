-- Source: airplane/Ton_Po.lua
-- Monk Plane of Sky tests: current P99 page names Back Straps of Mastery for Test of Strength.
-- items: 1282, 20793, 20794, 20932, 27714, 20796, 20939, 20795, 1281, 20946, 20798, 20797, 1280

function event_spawn(e)
	eq.set_timer("depop",300000);
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("So, I have been called upon to test you, and test you I shall. I will give you the option of choosing your test though, enlightened one. Shall you take the test of strength, sight, or speed or would you like to see something new I have just gotten.");
	elseif(e.message:findi("something new")) then
		e.self:Say("I am currently looking for Mystical Back Straps that I've misplaced. If you could find one Ill be glad to compensate you for it.");
	elseif(e.message:findi("strength")) then
		e.self:Say("So be it, the test of strength you shall have. Bring to me a verdant tessera, some finely woven gold mesh, and some silken strands. The task will not be easy, but it should serve as an adequate test of strength, for one of your abilities.");
	elseif(e.message:findi("sight")) then
		e.self:Say("The test of sight is a test of both body and mind. The mind will allow you to see that which is usually invisible. Bring me a gold disc, a tiny ruby, and a cracked leather eyepatch and I will assist you in seeing what should not be seen.");
	elseif(e.message:findi("speed")) then
		e.self:Say("The test of speed. Every monk must be swift if he is to best his opponent. Speed in both mind and body is essential in many facets of life. Return to me an adumbrate globe, a shimmering opal, and some dove slippers and I shall aid your speed of mind.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	-- P99 Old Sky explicitly permits one old reward for its listed upgrade.
	-- No XP, cash, faction or despawn value for this exchange is documented.
	if(item_lib.check_turn_in(e.trade, {item1 = 1282})) then
		e.other:SummonItem(27714);
	elseif(item_lib.check_turn_in(e.trade, {item1 = 20793, item2 = 20794, item3 = 20932})) then
		e.other:SummonItem(27714); -- Back Straps of Mastery
		e.other:AddEXP(100000);
		e.self:Say("You have done well, " .. e.other:GetName() .. ".");
		eq.depop();
	elseif(item_lib.check_turn_in(e.trade, {item1 = 20796, item2 = 20939, item3 = 20795})) then
		e.other:SummonItem(1281); -- Ton Po's Eye Patch
		e.other:AddEXP(100000);
		e.self:Say("You have done well, " .. e.other:GetName() .. ".");
		eq.depop();
	elseif(item_lib.check_turn_in(e.trade, {item1 = 20946, item2 = 20798, item3 = 20797})) then
		e.other:SummonItem(1280); -- Sandals of Alacrity
		e.other:AddEXP(100000);
		e.self:Say("You have done well, " .. e.other:GetName() .. ".");
		eq.depop();
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_timer(e)
	eq.stop_timer("depop");
	eq.depop();
end

