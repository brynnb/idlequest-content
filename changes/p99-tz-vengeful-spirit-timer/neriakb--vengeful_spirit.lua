-- Converted from ProjectEQ Perl quest script.
-- Source: neriakb/vengeful_spirit.pl
-- items: 18401, 6403

function event_spawn(e)
	eq.set_timer("despawn", 6000000)
end

function event_timer(e)
	if e.timer == "despawn" then
		eq.stop_timer("despawn")
		eq.depop()
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 18401}) then
		eq.stop_timer("despawn")
		e.self:Emote("flares brightly as you place the scroll into the blue flames of the forge. The scroll quickly catches fire and burns out in a flash of white fire. In it's place is left a hammer. As you snatch the hammer from the flames you hear the spirit begin to cackle wildly and fade away.")
		e.other:SummonItem(6403)
		e.other:AddEXP(132775)
		eq.depop()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
