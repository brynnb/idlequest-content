-- enabled: false
-- P99 source-only scope exclusion: later_beastlord_only. Historical callback body preserved byte-for-byte below.
-- Converted from ProjectEQ Perl quest script.
-- Source: timorous/Scout_Sihmoj.pl
-- items: 9045, 17360, 9047, 9048

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings friend, please show me the Seal of Elder Dumul and I will brief you on the situation.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 9045}) then
		e.self:Say("Good to see you, now keep your head down friend. He may look out here at any moment, though he's been asleep most of the day. He's been staying in a ruined building on that island over there. I'm sure you can see it from here. You should be able to surprise him with little trouble. Just take care to avoid any traps he may have set. He's proven to be a very capable magic-user.")
		e.self:Say("When you finish with him, please bring any evidence of his being dispatched back to me in this bag. I'll direct you from there. Good luck... I'll watch from here.")
		e.other:SummonItem(17360)
		eq.spawn2(96321, 0, 0, 1988, -9203, 10, 0)
	elseif item_lib.check_turn_in(e.trade, {item1 = 9047}) then
		e.self:Say("I knew that this creature had power, but how do you explain this? That fight was well beyond my comprehension. I'm not sure what to do other than have you return the bag to Elder Dumul. I'm sure that he will know what to do next. Take care and be swift.")
		e.other:SummonItem(9048)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
