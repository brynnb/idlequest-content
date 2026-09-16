-- Converted from ProjectEQ Perl quest script.
-- Source: hole/Kejar_the_Mighty.pl
-- P99 audit: Shiny Robe of the Underfoot Quest
-- P99 says Shiny Hunk of Metal is the more common reward; exact odds unknown.
-- items: 1360, 8960, 8961

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("I do not have time to talk to you, I am looking for something that I [lost]")
	elseif e.message:findi("lost") then
		e.self:Say("Yes, lost.  I am missing my robes if you could bring them to me I would reward you.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 1360}) then
		e.self:Say("You found it, I am so pleased! Here is your reward")
		e.other:SummonItem(eq.ChooseRandom(8961, 8961, 8961, 8960))
		e.other:AddEXP(5000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
