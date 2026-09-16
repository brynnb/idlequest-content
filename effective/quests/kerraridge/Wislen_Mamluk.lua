-- Converted from ProjectEQ Perl quest script.
-- Source: kerraridge/Wislen_Mamluk.pl
-- P99 audit: Wislen Mamluk's Catfish
-- items: 13019, 22748, 46996

function event_say(e)
	if e.message:findi("Hail") then
		e.self:Say("Why you bother Wislen? Wislen trying to get fishies. Leave Wislen alone to get [fish]. please.")
	elseif e.message:findi("fish") then
		e.self:Say("Fish. Wislen fish. Wislen is mamluk, not just fisher. Mamluk is warrior but they also helps provide for all [Kerran]. This is hadi place in life. We happy doing this. Please, let Wislen fish now.")
	elseif e.message:findi("kerran") then
		e.self:Say("Mostly they like [catfish], but Wislen not have any luck today.")
	elseif e.message:findi("catfish") then
		e.self:Say("Kerra Catfish is what Wislen want.")
	end
end

function event_trade(e)
	local item_lib = require("items")

	if item_lib.check_turn_in(e.trade, { item1 = 13019 }) then -- Fresh Fish
		e.self:Say("Fish! Fish! Not again Fish! Take it back, I have too many.")
		e.other:SummonItem(13019)
	elseif item_lib.check_turn_in(e.trade, { item1 = 22748 }) then -- Kerra Catfish
		e.self:Say("You caught catfish? Errr. Wislen thanks you. Here. Take this. It's one of my best fishing poles.")
		e.other:SummonItem(46996) -- Kerran Fishing Pole
		e.other:Faction(382, 5, 0) -- Kerra Isle
		e.other:AddEXP(500)
		e.other:Ding()
	end

	item_lib.return_items(e.self, e.other, e.trade)
end
