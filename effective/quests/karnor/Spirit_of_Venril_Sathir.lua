-- Source: karnor/Spirit_of_Venril_Sathir.pl
-- Ranger Epic 1.0: Spirit of Venril Sathir spawns Venril Sathir.
-- Converted from ProjectEQ Perl quest script.
-- items: 15392

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("So mortals, you seek to end the tainting of Tunare's children? So be it, I have no cares. My death has been caused by this foolishness and I want no more to do with it. Bring me a scroll with the knowledge of resurrection so that I may once again live. I will hand you that which you seek.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 15392}) then
		-- Perl interpolated $name; Lua requires the actual event player's name.
		e.self:Say("I am alive! My thanks to you, " .. e.other:GetName() .. ". And now I will aid you in your quest for preserving the forests of norrath. Your carcass will help nurture the soils of the wilderness.")
		-- The original Perl explicitly makes this concrete resurrected actor attack.
		eq.spawn2(102126, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()):AddToHateList(e.other, 1)
		eq.depop()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
