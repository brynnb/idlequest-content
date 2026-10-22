-- P99 documents legacy reward upgrades. No unquantified upgrade XP, coin or faction added.
-- Source: airplane/Denise_Songweaver.lua
-- items: 20947, 20824, 20825, 27722, 20940, 20822, 20823, 27721, 20933, 20820, 20821, 27720
function event_spawn(e)
	eq.set_timer("depop",300000);
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Hi there " .. e.other:GetName() .. "! I give three sections of the test of songs, Clarisa does the rest. Do you wish to take the test of pitch, voice, or tone?");
	elseif(e.message:findi("pitch")) then
		e.self:Say("The pitch that we sing and play has a great affect on those that listen.  Keep this in mind, and you shall always be welcome in taverns and inns.  Now if you return to me Phosphoric Globe, a Shimmering Diamond, and crude wooden flute I will give to you Ervaj's Flute of Flight.");
	elseif(e.message:findi("voice")) then
		e.self:Say("The sweet sound rising forth from our throats are what makes us truly great.  Go forth and give voice to your songs, and return to me a platinum disc, a music box, and a light woolen mantle. If you do this I shall give you the Songweaver's Mantle. Good luck!");
	elseif(e.message:findi("tone")) then
		e.self:Say("Tone is important to all singers. Prove to me that you can keep your tone even and pure by bringing me an Ochre Tessera, a songbird statuette, and a light woolen mask. If you do this I will give you the Mask of the Songbird.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 20947, item2 = 20824, item3 = 20825})) then -- Phosphoric Globe, Shimmering Diamond, Crude Wooden Flute
		e.other:SummonItem(27722); -- Ervaj's Flute of Flight
		e.other:AddEXP(100000);
		e.self:Say("Excellent! Take this as your reward.");
		eq.depop();
	elseif(item_lib.check_turn_in(e.trade, {item1 = 20940, item2 = 20822, item3 = 20823})) then -- Platinum Disc, Music Box, Light Woolen Mantle
		e.other:SummonItem(27721); -- Mantle of the Songweaver
		e.other:AddEXP(100000);
		e.self:Say("Excellent! Take this as your reward.");
		eq.depop();
	elseif(item_lib.check_turn_in(e.trade, {item1 = 20933, item2 = 20820, item3 = 20821})) then -- Ochre Tessera, Songbird Statuette, Light Woolen Mask
		e.other:SummonItem(27720); -- Mask of Song
		e.other:AddEXP(100000);
		e.self:Say("Excellent! Take this as your reward.");
		eq.depop();
	elseif(item_lib.check_turn_in(e.trade, {item1 = 2711})) then -- Mask of the Songbird
		e.other:SummonItem(27720); -- Mask of Song
	elseif(item_lib.check_turn_in(e.trade, {item1 = 2710})) then -- Songweaver's Mantle
		e.other:SummonItem(27721); -- Mantle of the Songweaver
	elseif(item_lib.check_turn_in(e.trade, {item1 = 14564})) then -- Agilmente's Flute of Flight
		e.other:SummonItem(27722); -- Ervaj's Flute of Flight
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_timer(e)
	eq.stop_timer("depop");
	eq.depop();
end
