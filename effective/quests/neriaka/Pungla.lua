-- Converted from ProjectEQ Perl quest script.
-- Source: neriaka/Pungla.pl
-- items: 13382

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Welcome! Drink you shall, some of de finest drinks of da lands! [Flaming Pungla] I suggest to you. It all me sells.")
	elseif e.message:findi("flaming pungla") then
		e.self:Say("Greatest drink and Plunga's creation. Buy one you should. Dey so gud me gots da charge t'ree golds.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {gold = 3}) then
		e.self:Say("Bottoms up!!")
		e.other:SummonItem(13382)
		e.other:Ding()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
