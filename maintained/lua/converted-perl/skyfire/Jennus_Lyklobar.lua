-- Source: skyfire/Jennus_Lyklobar.pl
-- Magician Epic 1.0: Jennus Lyklobar grants Element of Fire.
-- Converted from ProjectEQ Perl quest script.
-- items: 18958, 28007, 10376, 28008, 28009

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello and well met! Have you come for the element of Fire?")
	elseif e.message:findi("element of fire") then
		e.self:Say("Bring me the Torch of the Elements, burning embers, a blazing wand, and the tome Rykas gave you.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18958, item2 = 28007, item3 = 10376, item4 = 28008}) then
		e.self:Say("I see that you are well versed in the ways of Fire. Take this element, and guard it well.")
		e.other:SummonItem(28009) -- Element of Fire
		e.other:AddEXP(3000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
