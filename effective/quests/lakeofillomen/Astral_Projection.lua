-- IdleQuest epic 1.0 steps have no minimum level; preserve class and item checks.
-- Source: lakeofillomen/Astral_Projection.pl
-- Monk Epic 1.0: Astral Projection spawns Vorash and Deep.
-- Converted from ProjectEQ Perl quest script.
-- Reject ineligible characters before consuming their quest token.
-- items: 1687

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("ignores you.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if e.other:Class() == "Monk" and item_lib.check_turn_in(e.trade, {item1 = 1687}) then
		local x = e.self:GetX()
		local y = e.self:GetY()
		local z = e.self:GetZ()
		local h = e.self:GetHeading()
		eq.depop()
		eq.spawn2(85211, 0, 0, x, y, z, h) -- Vorash
		eq.spawn2(85223, 0, 0, x, y, z, h) -- Deep
	else
		e.self:Say("I have no use for this, $name.")
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
