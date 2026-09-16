-- Converted from ProjectEQ Perl quest script.
-- Source: neriakc/Mizr_N-Mar.pl
-- P99: https://wiki.project1999.com/Incandescent_Armor_Quests
-- items: 10532, 10791, 10792

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Have you come to buy a scroll from me?")
	elseif e.message:findi("coin") then
		e.self:Say("So, you want a coin do you?")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {gold = 50}) or item_lib.check_turn_in(e.trade, {platinum = 5}) then
		e.self:Say("I see that Sultin has sent you to me. Very well, here is your rune.")
		e.other:SummonItem(10532)
	elseif item_lib.check_turn_in(e.trade, {item1 = 10791}) then
		e.self:Say("Ah - the Coin of Tash - and already enchanted by.. ? Tarn? Very good! I have enchanted it further - you must now take the coin to Raine Beteria in the Library of Erudin to get the final enchantment.")
		e.other:SummonItem(10792)
		e.other:Faction(5029, 10, 0)
		e.other:Faction(416, -10, 0)
		e.other:AddEXP(1000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
