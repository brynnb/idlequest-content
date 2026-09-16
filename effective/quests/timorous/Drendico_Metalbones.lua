-- Source: timorous/Drendico_Metalbones.pl
-- Necromancer Epic 1.0: Drendico Metalbones reagent box chain.
-- Converted from ProjectEQ Perl quest script.
-- items: 20648, 18086, 1278, 20656, 20655, 20653

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("The hills ears keep spinning the wonders of wells. Twisting twisting fly in water scar hot horses. Teach me! Bring floating water islands of doom!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20648}) then
		e.self:Emote("throws a book over his shoulder. 'Bring back book! Bring back reagents three!!'")
		e.other:Ding()
		e.other:AddEXP(1000)
		e.other:SummonItem(18086) -- Journal of Drendico
	elseif item_lib.check_turn_in(e.trade, {item1 = 1278, item2 = 20656, item3 = 20655, item4 = 18086}) then
		e.self:Emote("fiddles with the components, puts them into a box and hands it to you.")
		e.other:SummonItem(20653) -- Prepared Reagent Box
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
