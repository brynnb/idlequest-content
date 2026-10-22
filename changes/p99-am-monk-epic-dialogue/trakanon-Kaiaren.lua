-- IdleQuest epic 1.0 steps have no minimum level; preserve class and item checks.
-- Source: trakanon/Kaiaren.pl
-- Monk Epic 1.0: mad Kaiaren returns Celestial Fists and spawns true Kaiaren.
-- Converted from ProjectEQ Perl quest script.
-- Check eligibility before the consuming hand-in matcher; reject without item loss.
-- items: 1683, 1684

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("AHHH get it away from me go away .. leave me alone")
	elseif e.message:findi("celestial fists") then
		e.self:Say("Eh? What's that? Bah! That was destroyed long ago. Don't waste my time with fairy taAAAAAGGHHH GET IT AWAY!!!! HELP!!! They're all over MEHEHEHEHEEEEEEee!!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if e.other:Class() == "Monk" and item_lib.check_turn_in(e.trade, {item1 = 1683}) then
		e.self:Emote("eyes open wide and he attacks you!")
		e.other:SummonItem(1683) -- Celestial Fists book
		eq.attack(e.other:GetName())
		eq.spawn2(95183, 0, 0, 2470, 306, -339, 0) -- true Kaiaren
	elseif e.other:Class() == "Monk" and item_lib.check_turn_in(e.trade, {item1 = 1684}) then
		e.self:Say("Ahhh, impressive indeed! Take this scale and show it to the Fist of Air wherever he may be. Good luck.")
		e.other:SummonItem(1684)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_death_complete(e)
	e.self:Say("Not bad.. Now lets see if you can find my trueform if you do we discuss this further.")
end
