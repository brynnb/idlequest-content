-- enabled: false
-- P99 excludes this exact later or custom-event quest chain; full callbacks retained.
-- Evidence: changes/p99-final-uncertainty/review.json
-- Source: neriaka/Bregna.pl
-- Converted from ProjectEQ Perl quest script.
-- items: 26662, 29921, 26640, 26632, 28740

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Me says hi to you. What you want from me? Oh!! Me shaman trainer. You must be shaman. Are you shaman Darkone?")
	elseif e.message:findi("shaman darkone") then
		e.self:Say("You choose rite if you bes a shaman. We's da best. You remember ta not get in Kaglari way. She get mad berry easy.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 26662, item2 = 29921, item3 = 26640, item4 = 26632}) then
		e.self:Say("Me been waitin for doze. Dank yoo, " .. e.other:GetName() .. ".  Take dis.")
		e.other:SummonItem(28740) -- Troll Receipt
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
