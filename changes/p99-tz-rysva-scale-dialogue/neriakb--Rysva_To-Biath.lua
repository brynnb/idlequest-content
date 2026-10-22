-- Converted from ProjectEQ Perl quest script.
-- Source: neriakb/Rysva_To-Biath.pl
-- items: 18200, 18201, 13846, 18202, 19071, 19070, 18302

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello.  Let me know if I can get you a drink.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18200}) then
		e.self:Say("Take this note and be gone with you.")
		e.other:SummonItem(18201)
		e.other:Faction(370, 10, 0)
		e.other:Faction(334, 10, 0)
		e.other:Faction(236, 10, 0)
		e.other:AddEXP(100)
		e.other:Ding()
	elseif item_lib.check_turn_in(e.trade, {item1 = 13846, item2 = 18201}) then
		e.self:Say("Take this book and be gone with you.")
		e.other:SummonItem(18202)
		e.other:Faction(370, 10, 0)
		e.other:Faction(334, 10, 0)
		e.other:Faction(236, 10, 0)
		e.other:AddEXP(72900)
	elseif item_lib.check_turn_in(e.trade, {item1 = 19071, item2 = 19070, platinum = 1000}) then
		e.self:Say("Take this book quickly and tell no one about this.")
		e.other:SummonItem(18302)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
