-- Converted from ProjectEQ Perl quest script.
-- Source: firiona/Lenka_Stoutheart.pl

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("We're just kidding with you, kid. Heh. Although they are making heroes kinda small these days. Hey, you [want to see something interesting]?")
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
