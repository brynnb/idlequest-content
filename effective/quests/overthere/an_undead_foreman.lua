-- Converted from ProjectEQ Perl quest script.
-- Source: overthere/an_undead_foreman.pl
-- items: 10023, 12863

function event_say(e)
	if e.message:findi("hail") then
		eq.zone_emote(MT.Emote, "an undead foreman turns to face you. You can see a faint green glow emanating from his vacant eye sockets.")
		e.self:Say("Are you a [new worker]? Huh? Speak or go!!")
	elseif e.message:findi("new worker") then
		e.self:Say("Hmmph!! Too much flesh!! If you want to work, you must first fill my eye sockets with my favorite gem. This shall be your payment for your sledgehammer.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10023}) then
		eq.zone_emote(MT.Emote, "an undead foreman places the gem deep within his hollow eye socket. He pulls a giant sledgehammer from thin air and hands it to you.")
		e.self:Say("Here!! You shall be assigned to the lower decks of the Scaled Trident.")
		e.other:SummonItem(12863)
	else
		e.self:Say("I do not know you well enough to entrust such an item to you, yet.")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
