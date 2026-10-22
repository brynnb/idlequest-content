-- IdleQuest epic 1.0 steps have no minimum level; preserve class and item checks.
-- Source: lakerathe/Deep.pl
-- Monk Epic 1.0: Deep grants access to Astral Projection.
-- Converted from ProjectEQ Perl quest script.
-- Validate eligibility before consuming the head.
-- items: 1686

function event_say(e)
	e.self:Emote("ignores you.")
end

function event_trade(e)
	local item_lib = require("items")
	if e.other:Class() == "Monk" and item_lib.check_turn_in(e.trade, {item1 = 1686}) then
		e.self:Emote("slowly opens her eyes and looks up at you. She stares at you a long while and then closes her eyes and lowers her head again.")
		e.self:Say("Very well, if you wish death so greatly, we will be happy to oblige. My master projects part of himself in the wilder lands known as the Overthere. He has granted you an audience. Find him and show him the head of our earth brother. At that point, we will discuss how we will end your life.")
		e.other:SummonItem(1686)
		eq.set_global("Trunt", "1", 5, "F")
		eq.depop()
	else
		e.self:Say("I have no use for this, " .. e.other:GetName() .. ".")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
