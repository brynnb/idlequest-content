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
		e.self:Say("I've done what I can to enchant your stone, but you will need to find Tarn Visilin in Highpass Keep to finish the enchantments.  Don't forget to pay him the same fee you gave me, or he may decide to keep the stone for himself!")
		e.other:SummonItem(10086)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
