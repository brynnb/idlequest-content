-- Converted from ProjectEQ Perl quest script.
-- Source: commons/Guard_Colin.pl

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail traveler. By order of Sir Lucan, the toll fee is one gold piece a head. Pay at once!!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {gold = 1}) then
		e.self:Say("It is best you donate to the Freeport Militia. I would hate to see something happen to you.")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
