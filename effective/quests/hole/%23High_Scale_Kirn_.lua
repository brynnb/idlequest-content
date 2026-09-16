-- Source: hole/#High_Scale_Kirn_.pl
-- Shaman Epic 1.0: High Scale Kirn trigger accepts Icon of the High Scale.
-- Converted from ProjectEQ Perl quest script.
-- items: 1671

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 1671}) then
		e.self:Emote("looks down at the icon in his hands for a long moment before speaking.")
		e.self:Say("Why did you bring me this? If you can take my ring, show it to the queen and she will remember. Defend yourself!")
		e.other:AddEXP(100000)
		local x = e.self:GetX()
		local y = e.self:GetY()
		local z = e.self:GetZ()
		local h = e.self:GetHeading()
		eq.spawn2(39083, 0, 0, x, y, z, h) -- attackable High Scale Kirn
		eq.depop()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
