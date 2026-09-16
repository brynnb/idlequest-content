-- Source: qeynos/Captain_Tillin.lua
-- P99 audit: Gnasher's Head
-- items: 13915, 10070, 18815, 13305, 18912

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Hail, " .. e.other:GetName() .. "! Spend your time wisely in the city of Qeynos. Do not let your mind wander to thoughts of bravado or crime. My guards can easily put to rest any outbreaks. Good day to you, citizen!");
	end
end

function event_signal(e)
	e.self:Say("Ah.  Good.  You have arrived.  Executioner, could you please visit McNeal Jocub at Fish's Tavern.  He has violated our laws and the sentence is death.");
	eq.signal(1202);
end

local function qeynos_guard_factions(e, amount)
	e.other:Faction(219, amount, 0); -- Antonius Bayle
	e.other:Faction(223, -amount, 0); -- Circle of Unseen Hands
	e.other:Faction(230, -amount, 0); -- Corrupt Qeynos Guards
	e.other:Faction(262, amount, 0); -- Guards of Qeynos
	e.other:Faction(291, amount, 0); -- Merchants of Qeynos
end

function event_trade(e)
	local item_lib = require("items");

	if(item_lib.check_turn_in(e.trade, {item1 = 13915, item2 = 13915, item3 = 13915, item4 = 13915})) then -- Gnoll Fang x 4
		e.self:Say("Very good! One less gnoll the people of Qeynos need to fear. Here is your bounty as promised.");
		e.other:SummonItem(10070); -- Moonstone
		e.other:SummonItem(10070); -- Moonstone
		e.other:SummonItem(10070); -- Moonstone
		e.other:SummonItem(10070); -- Moonstone
		e.other:Ding();
		qeynos_guard_factions(e, 4);
		e.other:AddEXP(28000);
	elseif(item_lib.check_turn_in(e.trade, {item1 = 13915, item2 = 13915, item3 = 13915})) then -- Gnoll Fang x 3
		e.self:Say("Very good! One less gnoll the people of Qeynos need to fear. Here is your bounty as promised.");
		e.other:SummonItem(10070); -- Moonstone
		e.other:SummonItem(10070); -- Moonstone
		e.other:SummonItem(10070); -- Moonstone
		e.other:Ding();
		qeynos_guard_factions(e, 3);
		e.other:AddEXP(21000);
	elseif(item_lib.check_turn_in(e.trade, {item1 = 13915, item2 = 13915})) then -- Gnoll Fang x 2
		e.self:Say("Very good! One less gnoll the people of Qeynos need to fear. Here is your bounty as promised.");
		e.other:SummonItem(10070); -- Moonstone
		e.other:SummonItem(10070); -- Moonstone
		e.other:Ding();
		qeynos_guard_factions(e, 2);
		e.other:AddEXP(14000);
	elseif(item_lib.check_turn_in(e.trade, {item1 = 13915})) then -- Gnoll Fang
		e.self:Say("Very good! One less gnoll the people of Qeynos need to fear. Here is your bounty as promised.");
		e.other:SummonItem(10070); -- Moonstone
		e.other:Ding();
		qeynos_guard_factions(e, 1);
		e.other:AddEXP(7000);
	elseif(item_lib.check_turn_in(e.trade, {item1 = 18815})) then
		e.self:Say("I heard you were on your way. I have called for the state executioner. She should be on her way now. She will deal with our friend, McNeal Jocub. Thank you for your help, citizen.");
		e.other:SummonItem(13305); -- Medal of Merit
		e.other:Ding();
		qeynos_guard_factions(e, 1);
		e.other:AddEXP(500);
		e.other:GiveCash(0, 1, 9, 6);
		eq.spawn2(1202,62,0,-412,75,-24,0); -- Executioner
	elseif(item_lib.check_turn_in(e.trade, {item1 = 18912})) then
		e.self:Say("So, an assassin has been sent to Qeynos! I shall have my guards keep an eye out for any suspicious looking visitors. As for you... you should speak with the Surefall Glade ambassador. Ambassador Gash is staying at the Lion's Mane Inn here in South Qeynos. Inform him that [an assassin has been sent to kill] him. Do not let the assassin near him!");
		e.other:Ding();
		qeynos_guard_factions(e, 1);
		e.other:AddEXP(500);
		e.other:GiveCash(math.random(10),math.random(10),math.random(10),math.random(10));
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
