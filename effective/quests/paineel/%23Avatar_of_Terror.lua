-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/#Avatar_of_Terror.pl
-- P99 audit: The Summoning of Terror
-- P99: https://wiki.project1999.com/The_Summoning_of_Terror
-- items: 14106, 14108

function event_spawn(e)
	eq.set_timer("TerrorShouting", 5000)
	eq.set_timer("TerrorDepop", 120000)
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 14106}) then
		e.self:Say("I grant you a mask crafted with my own essence! Wear it in honor of your devotion to our Lord Cazic Thule!")
		e.other:SummonItem(14108)
		e.other:Ding()
		e.other:Faction(265, 50, 0) -- Heretics
		e.other:Faction(242, -50, 0) -- Deepwater Knights
		e.other:Faction(254, -50, 0) -- Gate Callers
		e.other:Faction(231, -50, 0) -- Craftkeepers
		e.other:Faction(233, -50, 0) -- Crimson Hands
		e.other:AddEXP(1000)
		eq.stop_timer("TerrorShouting")
		eq.stop_timer("TerrorDepop")
		eq.depop()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_timer(e)
	if e.timer == "TerrorShouting" then
		eq.zone_emote(MT.Shout, "Grrrraaaarrrrg! The stench of fear permeates the walls of this city! I will forge one item for the faithful of our Lord Cazic-Thule! Make haste! My time here is short!")
	elseif e.timer == "TerrorDepop" then
		eq.stop_timer("TerrorShouting")
		eq.stop_timer("TerrorDepop")
		eq.depop()
	end
end
