-- Converted from ProjectEQ Perl quest script.
-- Source: firiona/Scout_Bladethorn.pl

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings! Keep an eye out for invaders. We may patrol the outpost, but every now and then a goblin or two manages to sneak in.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
