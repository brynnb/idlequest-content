-- Converted from ProjectEQ Perl quest script.
-- Source: paineel/Miadera_Shadowfyre.pl
-- P99 audit: The Summoning of Terror
-- P99: https://wiki.project1999.com/The_Summoning_of_Terror
-- items: 10523, 19032, 14110, 14109, 14106

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Ahhhahahaha! The terror that lays over this city like a blanket tingles my bones with vigor. I seek a fellow apostle of Cazic-Thule to assist me in the [summoning of Terror].")
	elseif e.message:findi("summoning of terror") then
		e.self:Say("It will be a frightfully fulfilling summons. To do this, I need an eye of urd, some basalt drake scales, the lens of Lord Soptyvr, and a lock of widowmistress hair.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10523, item2 = 19032, item3 = 14110, item4 = 14109}) then
		e.self:Say("Yes! Can you feel the terror in the air, prickling your flesh, and standing your hair on end? The chanters have summoned the avatar of Terror! Quickly take this mundane mask to him and he shall forge it into a valuable symbol to be worn by loyal apostles of Terror!")
		e.other:SummonItem(14106)
		e.other:Ding()
		e.other:Faction(265, 150, 0) -- Heretics
		e.other:Faction(242, -30, 0) -- Deepwater Knights
		e.other:Faction(254, -30, 0) -- Gate Callers
		e.other:Faction(231, -30, 0) -- Craftkeepers
		e.other:Faction(233, -30, 0) -- Crimson Hands
		e.other:AddEXP(1000)
		eq.unique_spawn(48240, 0, 0, 474, 1230, -37, 256) -- #Avatar_of_Terror
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
