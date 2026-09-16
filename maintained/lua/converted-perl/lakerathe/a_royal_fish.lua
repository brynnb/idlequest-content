-- Converted from ProjectEQ Perl quest script.
-- Source: lakerathe/a_royal_fish.pl
-- items: 12271

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("flutters about and seems to be staring back at you as if reading and understanding your thoughts!!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 12271}) then
		e.self:Emote("gladly gulps up your odd mixture and transforms into..!!")
		eq.unique_spawn(51176, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
		e.other:Ding()
		e.other:Faction(5001, 10, 0)
		e.other:Faction(226, 10, 0)
		e.other:Faction(279, 10, 0)
		eq.depop_with_timer()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
