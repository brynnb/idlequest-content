-- Source: oggok/Bozlum_Blossom.pl
-- Enchanter Epic 1.0: Bozlum Blossom snow blossoms chain.
-- Converted from ProjectEQ Perl quest script.
-- items: 10628, 10629, 10630, 10609

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("heaves a great sigh.")
	elseif e.message:findi("wrong") then
		e.self:Say("Boz like to grow perty flowers in her garden. But garden no more.")
	elseif e.message:findi("garden") then
		e.self:Say("Boz not know what happen. Only see der biggins footprints in it.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10628}) then
		e.self:Emote("writes something down on a piece of parchment.")
		e.self:Say("You go tell dat Brokk dat he owe me big for smushing garden.")
		e.other:SummonItem(10629) -- Scribbled Parchment
	elseif item_lib.check_turn_in(e.trade, {item1 = 10630}) then
		e.self:Say("Oh, dat silly Brokk. Here, you take some flowers.")
		e.other:AddEXP(100)
		e.other:SummonItem(10609) -- Snow Blossoms
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
