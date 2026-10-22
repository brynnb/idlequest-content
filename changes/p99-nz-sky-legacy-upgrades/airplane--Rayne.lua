-- Modified from ProjectEQ Lua.
-- Source: airplane/Rayne.lua
-- P99 audit: Rogue Plane of Sky Tests
-- items: 20963, 20994, 20995, 20996, 27704, 20949, 20990, 20991, 2701, 20935, 20987, 20986, 27702

function event_spawn(e)
	eq.set_timer("depop",300000);
end

function event_say(e)
	if e.message:findi("trade") then
		e.self:Say("Bartering is another important skill. Sometimes finding something that most consider junk can be useful to another for a whole different reason. Find me a Transparent Mask, Bracer of Protection or Ebonsting and I will search out a much better upgrade for you.");
		return;
	end
	if(e.message:findi("hail")) then
		e.self:Say("Great, let us waste no more time! Do you wish to begin your test of Deception, Stealth, or Cunning? Or would you like to [trade]?");
	elseif(e.message:findi("deception")) then
		e.self:Say("Deception it is. Proceed upward through the sky and return to me the honeyed nectar, a bixie stinger, a lightning rod, and a bloodsky sapphire for the test of deception and earn Thornstinger.");
	elseif(e.message:findi("stealth")) then
		e.self:Say("Stealth is a must. Travel among the residents of the sky and bring to me a Pegasus Statuette, a Prismatic Sphere, and a Fine Wool Cloak. In return, The Scintillating Bracer of Protection shall be yours.");
	elseif(e.message:findi("cunning")) then
		e.self:Say("Cunning, the true source of all rogue power. Plan and succeed above us and return to me a bronze disc, a jester's mask, and some red face paint to complete the test of cunning. The Crystal Mask shall be yours if you do so.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 20963, item2 = 20994, item3 = 20995, item4 = 20996})) then
		e.other:SummonItem(27704); -- Thornstinger
		e.other:AddEXP(100000);
		e.self:Say("Very good. Here's your reward.");
		eq.depop();
	elseif(item_lib.check_turn_in(e.trade, {item1 = 20949, item2 = 20990, item3 = 20991})) then
		e.other:SummonItem(2701); -- Scintillating Bracer of Protection
		e.other:AddEXP(100000);
		e.self:Say("Very good. Here's your reward.");
		eq.depop();
	elseif(item_lib.check_turn_in(e.trade, {item1 = 20935, item2 = 20987, item3 = 20986})) then
		e.other:SummonItem(27702); -- Crystal Mask
		e.other:AddEXP(100000);
		e.self:Say("Very good. Here's your reward.");
		eq.depop();
	elseif item_lib.check_turn_in(e.trade, {item1 = 2702}) then
		e.other:SummonItem(27702); -- Documented old Sky reward upgrade.

	elseif item_lib.check_turn_in(e.trade, {item1 = 11677}) then
		e.other:SummonItem(27704); -- Documented old Sky reward upgrade.

	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_timer(e)
	if e.timer == "depop" then
	eq.stop_timer("depop");
	eq.depop();
	end
end
