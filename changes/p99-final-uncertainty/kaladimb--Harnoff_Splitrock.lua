-- enabled: false
-- P99 excludes this exact later or custom-event quest chain; full callbacks retained.
-- Evidence: changes/p99-final-uncertainty/review.json
-- Converted from ProjectEQ Perl quest script.
-- Source: kaladimb/Harnoff_Splitrock.pl
-- items: 17814, 10952, 10953

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetins to ya friend Dwarf! I've got some of the finest quality steel ores in all the lands! It's a bit troublesome ta keep a large enough supply of it though, it bein sought after by every smith ya know. If you're needin some cash or ore how bout you [run an errand] fer me?")
	elseif e.message:findi("run an errand") then
		e.self:Say("I was hopin you'd be up fer the job! Take this here crate and fill it with either Small Bricks of Unrefined Ore or Large Bricks of Unrefined Ore and I'll pay ya when ye return.")
		e.other:SummonItem(17814)
	end
end

local function ore_reward(e, exp, platinum)
	e.other:AddEXP(exp)
	e.other:GiveCash(0, 0, 0, platinum)
	e.other:Faction(274, 5, 0)
	e.other:Faction(290, 5, 0)
	e.other:Faction(322, -5, 0)
	e.other:Faction(293, 5, 0)
	e.other:Faction(312, 5, 0)
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10952}) then
		ore_reward(e, 2000, 8)
	elseif item_lib.check_turn_in(e.trade, {item1 = 10953}) then
		ore_reward(e, 3500, 14)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
