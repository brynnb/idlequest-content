-- enabled: false
-- P99 source-only scope exclusion: later_epic_only. Historical callback body preserved byte-for-byte below.
-- Converted from ProjectEQ Perl quest script.
-- Source: steamfont/#Biddliss_Sperandu.pl
-- items: 9831, 9579, 27982, 21799

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Go away before I sic the clockworks on ya!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 9831}) then
		e.self:Say("Kazen wants some research tools? That is fine. I want something from you first, however. Bring me four gleaming zraxthil ores and combine them in this satchel. Why do I want them? Why do you care? Bring them to me or you don't get your tools. Now scram!")
		e.other:SummonItem(9579)
	elseif item_lib.check_turn_in(e.trade, {item1 = 27982}) then
		e.self:Say("So you're not totally useless after all. Maybe there is a reason Kazen hasn't destroyed you yet. Take these tools and give my warmest regards to Master Kazen.")
		e.other:SummonItem(21799)
		eq.depop_with_timer()
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
