-- Converted from ProjectEQ Perl quest script.
-- Source: gfaydark/Jakum_Webdancer.pl
-- items: 18161, 18160, 18162, 18163

local function reward_mail(e, gold)
	e.self:Say("Incoming mail - very good!  Please take this gold for your troubles.")
	e.other:GiveCash(0, 0, gold, 0)
	e.other:AddEXP(1550)
	e.other:Faction(284, 5, 0)
	e.other:Faction(281, 1, 0)
	e.other:Faction(262, 1, 0)
	e.other:Faction(304, -1, 0)
	e.other:Faction(285, -1, 0)
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail. " .. e.other:GetName() .. " - If you are interested in helping the League of Antonican Bards by delivering some mail then you should talk to Idia.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18161}) then
		reward_mail(e, math.random(11))
	elseif item_lib.check_turn_in(e.trade, {item1 = 18162}) then
		reward_mail(e, 8)
	elseif item_lib.check_turn_in(e.trade, {item1 = 18160}) or item_lib.check_turn_in(e.trade, {item1 = 18163}) then
		reward_mail(e, eq.ChooseRandom(6, 7, 8, 9))
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
