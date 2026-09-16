-- Converted from ProjectEQ Perl quest script.
-- Source: warslikswood/Trooper_Roklon.pl
-- items: 18247, 12672, 18248

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail! Beware the giants of the woods. They have a dwelling somewhere out there. Should you stumble upon it, run! Leave the fighting to us.")
	elseif e.message:findi("sign the restraining order") then
		e.self:Say("I've been ratted out! Very well. I shall sign the order, but first I shall force you to fetch me a set of goblin scout beads. I hear they make fine counters. Bring me the beads and that despicable order and I shall do as instructed.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18247, item2 = 12672}) then
		e.other:SummonItem(18248)
		e.other:AddEXP(500)
	elseif item_lib.check_turn_in(e.trade, {item1 = 18247}) then
		e.self:Say("No, NO! I want the goblin scout beads and the legion order.")
		e.other:SummonItem(18247)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12672}) then
		e.self:Say("No, NO! I want the goblin scout beads and the legion order.")
		e.other:SummonItem(12672)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
