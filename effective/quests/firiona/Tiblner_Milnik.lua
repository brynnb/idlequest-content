-- Source: firiona/Tiblner_Milnik.pl
-- Magician Epic 1.0: Tiblner Milnik grants Element of Earth.
-- Converted from ProjectEQ Perl quest script.
-- items: 11567, 28042, 6360, 6361, 28032

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("I am the Master of Earth. Are you interested in obtaining the Element of Earth?")
	elseif e.message:findi("element of earth") then
		e.self:Say("Bring the Staff of Elemental Mastery: Earth, Dirt of Underfoot, Broom of Trilon, and Shovel of Ponz.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 11567, item2 = 28042, item3 = 6360, item4 = 6361}) then
		e.self:Say("Take this Element and keep it with you.")
		e.other:SummonItem(28032) -- Element of Earth
		e.other:AddEXP(5000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
