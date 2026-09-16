-- Converted from ProjectEQ Perl quest script.
-- Source: cabwest/Izarod_Fristan.pl
-- items: 19423, 19296, 19294, 19299, 19297, 19421, 19408, 19409

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hail there. " .. e.other:GetName() .. ". So you are ready to learn more about our ways? Do you wish to try and expand your knowledge of our arcane arts? Then venture far from here to the darkest depths of our once great empire and seek the minions that inhabit the ruins. The arcane powers will come in the form of [scrolls].")
	elseif e.message:findi("what scrolls") then
		e.self:Say("Besides all the ones you will find. there are some that are only in my possession. To show that you have been successful on your journey. return one of splurt. defoliation. convergence. or thrall of bones. You then will be rewarded with one of my scrolls.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 19423}) or item_lib.check_turn_in(e.trade, {item1 = 19296}) or item_lib.check_turn_in(e.trade, {item1 = 19294}) or item_lib.check_turn_in(e.trade, {item1 = 19299}) then
		e.self:Say("Here is the scroll that I promised. We have both gained much today. I hope to do business with you again soon. Farewell.")
		e.other:SummonItem(eq.ChooseRandom(19297, 19421, 19408, 19409))
		e.other:AddEXP(1000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
