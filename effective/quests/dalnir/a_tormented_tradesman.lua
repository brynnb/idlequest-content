-- Converted from ProjectEQ Perl quest script.
-- Source: dalnir/a_tormented_tradesman.pl
-- items: 3889, 3896

local function spawn_haggle_baron(e, return_cracked_mirror)
	e.self:Emote("The undead entity looks in the mirror and appears to be stunned by the memory of his former self. He drops the mirror, which causes it to crack slightly. You immediately grab it and place it back in your bag. The spirit looks at you and begins to transform. Ethereal strands of muscle, blood, and flesh come together and the Haggle Baron Dalnir appears.")
	if return_cracked_mirror then
		e.other:SummonItem(3896)
	end
	e.other:Ding()
	eq.spawn2(104075, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
	eq.depop_with_timer()
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 3889}) then
		spawn_haggle_baron(e, true)
	elseif item_lib.check_turn_in(e.trade, {item1 = 3896}) then
		spawn_haggle_baron(e, false)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
