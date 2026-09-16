-- Source: kaladimb/Kinlo_Strongarm.pl
-- Ranger Epic 1.0: Kinlo handles Enchanted Clay and Refined Mithril Blade steps.
-- Converted from ProjectEQ Perl quest script.
-- items: 5664, 20455, 20478, 20485, 20482, 20483

function event_say(e)
	if e.message:findi("mud") then
		e.self:Say("If ye be one o' those pansy elves wantin' some mud then I can get it for ye.")
	elseif e.message:findi("do it for me") then
		e.self:Say("Go get me a good strong axe and I'll do it fer ye.")
	elseif e.message:findi("ancient longsword") then
		e.self:Say("The ancient smiths ain't been around fer a long time, laddy.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 5664}) then
		e.self:Say("Here's yer block o' mud.")
		e.other:SummonItem(20455) -- Enchanted Clay
	elseif item_lib.check_turn_in(e.trade, {item1 = 20478}) then
		e.self:Emote("examines the hammer respectfully.")
		e.other:SummonItem(20478) -- Soulbound Hammer
	elseif item_lib.check_turn_in(e.trade, {item1 = 20485}) then
		e.self:Emote("shatters the hammer head.")
		e.other:SummonItem(20482) -- Small bit of Mithril Ore
		eq.spawn2(67089, 0, 0, -189.5, 346.8, 1.8, 69) -- Usbak_the_Old
	elseif item_lib.check_turn_in(e.trade, {item1 = 20482}) then
		e.self:Say("Here's what I got for ya.")
		e.other:SummonItem(20483) -- Refined Mithril Blade
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
