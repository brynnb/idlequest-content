-- IdleQuest epic 1.0 steps have no minimum level; preserve class and item checks.
-- Source: trakanon/#Kaiaren.pl
-- Monk Epic 1.0: true Kaiaren converts the book and performs final turn-in.
-- Converted from ProjectEQ Perl quest script.
-- Check eligibility before the consuming hand-in matcher; reject without item loss.
-- items: 1683, 1684, 1688, 1689, 10652

function event_spawn(e)
	eq.set_timer("depop", 3600000)
end

function event_say(e)
	if e.other:HasItem(1689) then
		if e.message:findi("lheao") then
			e.self:Say("Hmmm, never heard of him. Well, it doesn't matter, the book is here now. I suppose you'd like to find the Fists and have a nice chat with them, eh?")
		elseif e.message:findi("have a nice chat with them") then
			e.self:Say("No, you will need to get their attention. Fortunately, I know how you can do this.")
		elseif e.message:findi("how can i do this") then
			e.self:Say("If you use his true name, Eejag, in your formal challenge, he will respond.")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	if e.other:Class() == "Monk" and item_lib.check_turn_in(e.trade, {item1 = 1683}) then
		e.self:Say("Now, then. Where did you find this, monk? This is not just some light reading to be borrowed from the town library. Who gave this to you?")
		e.other:SummonItem(1689) -- Book of Celestial Fists
	elseif e.other:Class() == "Monk" and item_lib.check_turn_in(e.trade, {item1 = 1684}) then
		e.self:Say("Ahhh, impressive indeed! Take this scale and show it to the Fist of Air wherever he may be. Good luck.")
		e.other:SummonItem(1684)
	elseif e.other:Class() == "Monk" and item_lib.check_turn_in(e.trade, {item1 = 1688, item2 = 1689}) then
		e.self:Say("I honestly did not believe you could have defeated Vorash. I will sew these fangs into magical fist wraps and they shall be yours.")
		e.other:SummonItem(10652) -- Celestial Fists epic
		eq.set_global("MnkEpic1", "1", 5, "Y1")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_timer(e)
	if e.timer == "depop" then
		eq.depop()
	end
end
