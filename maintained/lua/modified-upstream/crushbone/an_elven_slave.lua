-- Modified from ProjectEQ Lua.
-- Source: crushbone/an_elven_slave.lua
-- P99 audit: Slave Keys
-- items: 20020, 10351, 18901, 20021, 18902, 20018, 18903, 20019, 18904

local function faction_ok(e)
	return e.other:GetFaction(e.self) <= 7 -- dubious or better
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Slavedrivers are just lackeys for the [taskmaster]. He is the real orc in charge.");
	elseif(e.message:findi("taskmaster")) then
		e.self:Say("The taskmaster?? He is that large orc who runs around with that [bronze earring] in his ear.");
	elseif(e.message:findi("bronze earring")) then
		e.self:Say("Yeah, a bronze earring; He wears it like a newly crowned king. If I ever had that earring I know I would stand a chance at escape.");
	end
end

function event_trade(e)
	local item_lib = require("items");

	if(e.self:GetRace() == 5 and e.self:GetGender() == 0) then -- male high elf slave
		if(item_lib.check_turn_in(e.trade, {copper = 1})) then
			e.self:Say("Not that!! I need key number 20!!");
		elseif(item_lib.check_turn_in(e.trade, {item1 = 20020})) then
			if not faction_ok(e) then
				e.self:Say("Please go away. The orcs might see you and me talking and slay us both!")
				e.other:SummonItem(20020)
			else
				e.self:Say("Good work!! I shall be on my way. Farewell my friend!!");
				e.other:Ding();
				e.other:Faction(275,2,0); -- Keepers of the Art
				e.other:Faction(279,1,0); -- King Tearis Thex
				e.other:Faction(246,1,0); -- Faydarks Champions
				e.other:Faction(239,-1,0); -- The Dead
				e.other:AddEXP(800);
				e.other:GiveCash(0,0,3,0);
				eq.depop_with_timer();
			end
		elseif(item_lib.check_turn_in(e.trade, {item1 = 10351})) then
			e.self:Say("You killed the taskmaster?!  Absolutely amazing! The orcs will be fighting among themselves for power now and I can disappear in the commotion. Thanks, friend! Take this for your deeds!");
			e.other:Ding();
			e.other:SummonItem(18901); -- Ragged Cloth Note
			e.other:AddEXP(5000);
			eq.depop_with_timer();
		end
	elseif(e.self:GetRace() == 5 and e.self:GetGender() == 1) then -- female high elf slave
		if(item_lib.check_turn_in(e.trade, {copper = 1})) then
			e.self:Say("Please!! I need a key with a number 21!!");
		elseif(item_lib.check_turn_in(e.trade, {item1 = 20021})) then
			if not faction_ok(e) then
				e.self:Say("Please go away. The orcs might see you and me talking and slay us both!")
				e.other:SummonItem(20021)
			else
				e.self:Say("Good work!! I shall be on my way. Farewell my friend!!");
				e.other:Ding();
				e.other:Faction(275,2,0); -- Keepers of the Art
				e.other:Faction(279,1,0); -- King Tearis Thex
				e.other:Faction(246,1,0); -- Faydarks Champions
				e.other:Faction(239,-1,0); -- The Dead
				e.other:AddEXP(800);
				e.other:GiveCash(0,2,2,2);
				eq.depop_with_timer();
			end
		elseif(item_lib.check_turn_in(e.trade, {item1 = 10351})) then
			e.self:Say("You killed the taskmaster?!  Absolutely amazing! The orcs will be fighting among themselves for power now and I can disappear in the commotion. Thanks, friend! Take this for your deeds!");
			e.other:Ding();
			e.other:SummonItem(18902); -- Torn Drawing
			e.other:AddEXP(5000);
			eq.depop_with_timer();
		end
	elseif(e.self:GetRace() == 4 and e.self:GetGender() == 0) then -- male wood elf slave
		if(item_lib.check_turn_in(e.trade, {copper = 1})) then
			e.self:Say("Not that!! I need key number 18!!");
		elseif(item_lib.check_turn_in(e.trade, {item1 = 20018})) then
			if not faction_ok(e) then
				e.self:Say("Please go away. The orcs might see you and me talking and slay us both!")
				e.other:SummonItem(20018)
			else
				e.self:Say("Good work!! I shall be on my way. Farewell my friend!!");
				e.other:Ding();
				e.other:Faction(326,2,0); -- Emerald Warriors
				e.other:Faction(270,1,0); -- Indigo Brotherhood
				e.other:Faction(325,1,0); -- Merchants of Felwithe
				e.other:Faction(276,1,0); -- Kelethin Merchants
				e.other:Faction(232,-1,0); -- Craknek Warriors
				e.other:AddEXP(800);
				e.other:GiveCash(0,4,0,0);
				eq.depop_with_timer();
			end
		elseif(item_lib.check_turn_in(e.trade, {item1 = 10351})) then
			e.self:Say("You killed the taskmaster?!  Absolutely amazing! The orcs will be fighting among themselves for power now and I can disappear in the commotion. Thanks, friend! Take this for your deeds!");
			e.other:Ding();
			e.other:SummonItem(18903); -- Tattered Cloth Note
			e.other:AddEXP(5000);
			eq.depop_with_timer();
		end
	elseif(e.self:GetRace() == 4 and e.self:GetGender() == 1) then -- female wood elf slave
		if(item_lib.check_turn_in(e.trade, {copper = 1})) then
			e.self:Say("Please!! I need a key with a number 19!!");
		elseif(item_lib.check_turn_in(e.trade, {item1 = 20019})) then
			if not faction_ok(e) then
				e.self:Say("Please go away. The orcs might see you and me talking and slay us both!")
				e.other:SummonItem(20019)
			else
				e.self:Say("Good work!! I shall be on my way. Farewell my friend!!");
				e.other:Ding();
				e.other:Faction(326,2,0); -- Emerald Warriors
				e.other:Faction(270,-1,0); -- Indigo Brotherhood
				e.other:Faction(325,1,0); -- Merchants of Felwithe
				e.other:Faction(276,1,0); -- Kelethin Merchants
				e.other:AddEXP(800);
				e.other:GiveCash(0,6,0,0);
				eq.depop_with_timer();
			end
		elseif(item_lib.check_turn_in(e.trade, {item1 = 10351})) then
			e.self:Say("You killed the taskmaster?!  Absolutely amazing! The orcs will be fighting among themselves for power now and I can disappear in the commotion. Thanks, friend! Take this for your deeds!");
			e.other:Ding();
			e.other:SummonItem(18904); -- Faded Wedding Cloth
			e.other:AddEXP(5000);
			eq.depop_with_timer();
		end
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
