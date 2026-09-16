-- Converted from ProjectEQ Perl quest script.
-- Source: lakerathe/Grud.pl
-- items: 10073, 19050

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Gimme duffynitey rocks! Me crushem GUUD!!!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10073}) then
		e.self:Emote("takes the dufrenite and crushes it with his bare hands.")
		e.self:Say("Here ya go!")
		e.other:SummonItem(19050)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
