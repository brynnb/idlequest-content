-- Source: mistythicket/Fajio_Knejo.pl
-- Bard Epic 1.0: Fajio Knejo advances the torch relay.
-- Converted from ProjectEQ Perl quest script.
-- items: 20532, 20533

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings, " .. e.other:GetName() .. ". I hope you are having a fine day.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 20532}) then
		e.self:Say("Run onward, my friend, to the far off Desert of Ro and give this torch to Andad Filla.")
		e.other:SummonItem(20533) -- Torch of Ro
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
