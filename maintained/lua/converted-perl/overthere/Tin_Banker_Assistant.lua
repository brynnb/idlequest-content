-- Source: overthere/Tin_Banker_Assistant.pl
-- Converted from ProjectEQ Perl quest script.
-- items: 12849, 55978

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Insert Metal Key *whirrrr*.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12849}) then -- Metal Key
		e.self:Say("*Whirrrr*")
		e.other:SummonItem(55978) -- Dusty Tome
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
