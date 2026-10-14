-- Source: karnor/Venril_Sathirs_remains.pl
-- Ranger Epic 1.0: Venril Sathir's remains spawns the Spirit of Venril Sathir.
-- Converted from ProjectEQ Perl quest script.
-- items: 10295

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("The living fire. I seek the fires of life. Bring them.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 10295}) then
		e.self:Emote("grasps the glowing sphere of fireflies from your hands.")
		eq.spawn2(102123, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
		-- Preserve the original Perl's respawn timer after the successful hand-in.
		eq.depop_with_timer()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
