-- Converted from ProjectEQ Perl quest script.
-- Source: rathemtn/Cynthia.pl
-- items: 10085, 10086

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello. I am Cynthia.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10085, gold = 50}) then
		e.self:Say("I have enchanted your Shining Stone. To get it further enchanted, take this stone to Tarn Visilin in HighKeep. Tip him 50 golden coins and he will work his magic.")
		e.other:SummonItem(10086)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
