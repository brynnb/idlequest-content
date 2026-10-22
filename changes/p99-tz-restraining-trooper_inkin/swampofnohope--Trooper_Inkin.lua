-- Converted from ProjectEQ Perl quest script.
-- Source: swampofnohope/Trooper_Inkin.pl
-- items: 18243, 12425, 18244

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Many frogloks in here. Beware! They can be a sneaky bunch. I hear tales of a froglok village nearby.")
	elseif e.message:findi("sign the restraining order") or e.message:findi("sign this restraining order") then
		e.self:Say("I have been expecting this. Oh, well... Can't argue with the Baron or he will have both our heads. Keeping that in mind, I will make you a deal. I will sign the order if you bring me one of those grand skipping stones these Frogloks are said to have. Bring me the stone and the order and I shall sign.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18243, item2 = 12425}) then
		e.self:Say("So smooth. I shall be the skipping stone champion! Here. You may have my autograph.")
		e.other:SummonItem(18244)
		e.other:AddEXP(500)
		e.other:GiveCash(7, 0, 0, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 18243}) then
		e.self:Say("No deal! You bring me the legion order and the froglok skipping stone.")
		e.other:SummonItem(18243)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12425}) then
		e.self:Say("No deal! You bring me the legion order and the froglok skipping stone.")
		e.other:SummonItem(12425)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
