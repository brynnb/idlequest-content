-- Modified from ProjectEQ Lua.
-- Source: airplane/Tynicon_DLin.lua
-- P99 audit: Shadow Knight Plane of Sky Tests
-- items: 20950, 20703, 20704, 4322, 20705, 20957, 20706, 11678, 20707, 20708, 20709, 20710, 11699, 20711, 20964, 20713, 20712, 27707

function event_spawn(e)
	eq.set_timer("depop",300000);
end

function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Great, let us waste no more time! I offer to you four challenges. Disempowement, Envenoming, Raising of the Dead, or Necropotence. Choose one to be tested on.");
	elseif(e.message:findi("disempowerment")) then
		e.self:Say("Disempowerment, destroying good magic. Proceed upward through the sky and return to me a Griffon Statuette, a Blood Sky Emerald, and Rusted Pauldrons. This will prove your abilities to me and I will reward you with Blood Sky Face plate.");
	elseif(e.message:findi("envenoming")) then
		e.self:Say("Venom and hate permeates us more than our dumber, larger brohers. Return to me a Efreeti War Shield, a Dark Spiroc Feather, and an Obsidian shard and prove that your soul is envenomed with hatred. If you do so the Obtenebrate Mithril Guard shall be yours.");
	elseif(e.message:findi("raising of the dead")) then
		e.self:Say("The dead are our allies against those that would oppose us. Proceed upward through the sky and return to me a Large Sky Pearl, a Jar of Honey, a Sphinxian Ring, and Fae Pauldrons. This will prove your abilities to me and I will reward you with an Pearlescent Pauldrons.");
	elseif(e.message:findi("necropotence")) then
		e.self:Say("Only the most powerful and vile of shadow knights manage to complete this test. Return to me an Efreeti War Axe, some Dulcet Nectar, a Bloodstained Hilt, and a Blood Sky Ruby. Doing so will earn you the right to wield Khyldorn the Blood Drinker.");
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 20950, item2 = 20703, item3 = 20704})) then
		e.other:SummonItem(4322); -- Blood Sky Face Plate
		e.other:AddEXP(100000);
		e.self:Say("You have learned the ways of Disempowerment.");
		eq.depop();
	elseif(item_lib.check_turn_in(e.trade, {item1 = 20705, item2 = 20957, item3 = 20706})) then
		e.other:SummonItem(11678); -- Obtenebrate Mithril Guard
		e.other:AddEXP(100000);
		e.self:Say("You soul is truly envenomed with hate.");
		eq.depop();
	elseif(item_lib.check_turn_in(e.trade, {item1 = 20707, item2 = 20708, item3 = 20709, item4 = 20710})) then
		e.other:SummonItem(11699); -- Pearlescent Pauldrons
		e.other:AddEXP(100000);
		e.self:Say("You have proven your abilities.");
		eq.depop();
	elseif(item_lib.check_turn_in(e.trade, {item1 = 20711, item2 = 20964, item3 = 20713, item4 = 20712})) then
		e.other:SummonItem(27707); -- Khyldorn the Blood Drinker
		e.other:AddEXP(100000);
		e.self:Say("You have truly earned this.");
		eq.depop();
	elseif(item_lib.check_turn_in(e.trade, {item1 = 11679})) then
		e.other:SummonItem(27707); -- Documented Old Sky upgrade; no quantified extra rewards.
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_timer(e)
	eq.stop_timer("depop");
	eq.depop();
end
