-- Converted from ProjectEQ Perl quest script.
-- Source: dreadlands/gem_cutter_skeleton.pl
-- items: 10073, 12946

function event_say(e)
	if e.message:findi("hail") then
		e.self:DoAnim(39)
		e.self:Emote("appears to be busy cutting a green gem; upon your greeting, it jumps, fleshless hands slipping carelessly and breaking the gem into powder.")
		eq.set_timer("distracted", 2000)
	elseif e.message:findi("green gem") then
		e.self:Say("The greenest of gems I seek! Jade too brittle, emerald too hard, but [dufrenite]! Ahh, now there is a gem amongst gems.")
	elseif e.message:findi("dufrenite") then
		e.self:Say("Yes, dufrenite! Find me a dufrenite to replace the one you made me break. Now go!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10073}) then
		e.self:Emote("eyes sparkle as you hand it the gem.")
		e.self:Say("Yes! Yes! This is the greenest of gems!")
		e.other:SummonItem(12946)
		e.self:Say("Worth more to you crushed, that is! Find a spectral pestle, and crush it to dust!")
		e.other:AddEXP(3000)
		eq.set_timer("cutting", 4000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_timer(e)
	if e.timer == "distracted" then
		e.self:DoAnim(20)
		e.self:Say("Blast it! Distracted me you have! Now I need a new [green gem]!")
		eq.stop_timer("distracted")
	elseif e.timer == "cutting" then
		e.self:Emote("carries on cutting gems, oblivious to your presence.")
		e.self:DoAnim(39)
		eq.stop_timer("cutting")
	end
end
