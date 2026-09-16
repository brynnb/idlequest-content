-- Source: airplane/Clarisa_Spiritsong.lua
-- items: 20830, 20961, 20828, 20829, 27724, 20953, 20826, 20827, 27723, 20831, 20968, 20832, 20833, 10852
function event_spawn(e)
	eq.set_timer("depop",300000);
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Hail and well met " .. e.other:GetName() .. "! I give the second half of the test of songs. If you are ready, choose between the tests of brass, wind, and harmony.");
	elseif(e.message:findi("brass")) then
		e.self:Say("Then bring back to me an Efreeti War Horn, a Saffron Spiroc Feather, Adamintium Bands, and a Glowing Diamond. Then I will give you the horn of disaster.");
	elseif(e.message:findi("wind")) then
		e.self:Say("Bring me an imp statuette, a dull stone, and an amulet of woven hair. Then I will give you the fae amulet.");
	elseif(e.message:findi("harmony")) then
		e.self:Say("Working with the environment to enthrall those that listen to you is of the utmost importance to us. Go out and retrieve an efreeti war spear, some manna nectar, a nebulous emerald, and a nebulous diamond. Return these items to me and receive the harmonic spear as your reward.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 20830, item2 = 20961, item3 = 20828, item4 = 20829})) then -- Efreeti War Horn, Saffron Spiroc Feather, Adamantium Bands, Glowing Diamond
		e.other:SummonItem(27724); -- Denon's Horn of Disaster
		e.other:AddEXP(100000);
		e.self:Say("Well done, " .. e.other:GetName() .. ". Here is your reward.");
		eq.depop();
	elseif(item_lib.check_turn_in(e.trade, {item1 = 20953, item2 = 20826, item3 = 20827})) then -- Imp Statuette, Dull Stone, Amulet of Woven Hair
		e.other:SummonItem(27723); -- Amulet of the Fae
		e.other:AddEXP(100000);
		e.self:Say("Well done, " .. e.other:GetName() .. ". Here is your reward.");
		eq.depop();
	elseif(item_lib.check_turn_in(e.trade, {item1 = 20831, item2 = 20968, item3 = 20832, item4 = 20833})) then -- Efreeti War Spear, Manna Nectar, Nebulous Emerald, Nebulous Diamond
		e.other:SummonItem(10852); -- Harmonic Spear
		e.other:AddEXP(100000);
		e.self:Say("Well done, " .. e.other:GetName() .. ". Here is your reward.");
		eq.depop();
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_timer(e)
	eq.stop_timer("depop");
	eq.depop();
end
