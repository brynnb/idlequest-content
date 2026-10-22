-- enabled: false
-- P99 source-only scope exclusion: later_epic_only. Historical callback body preserved byte-for-byte below.
-- Converted from ProjectEQ Perl quest script.
-- Source: lakerathe/#Egonis.pl
-- items: 15523

local function necro_pre_active(e)
	local qglobals = eq.get_qglobals(e.other)
	return qglobals["NecroPre"] == "1"
end

function event_say(e)
	if e.message:findi("hail") then
		if necro_pre_active(e) and not e.other:HasItem(20612) then
			e.self:Say("So the foolish brigand sold the staff to Ronaiar, eh? Who is Ronaiar? He is an insane necromancer that makes his home somewhere near the lake. I had a feeling he would try to get his hands on the staff. That is why I came out here. I must inform Kazen of this turn of events and you must destroy that decrepit fool, Ronaiar. If you find the staff, give it to Geboron.")
			eq.unique_spawn(51155, 0, 0, 1010, 2690, -23, 0)
		else
			e.self:Say("The lake's depths hold so many secrets. Unless you have a reason to be bothering me, I would suggest you leave, before you become another 'secret'.")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	if e.other:Class() == "Necromancer" and item_lib.check_turn_in(e.trade, {item1 = 15523}) then
		e.self:Say("So the foolish brigand sold the staff to Ronaiar, eh? Who is Ronaiar? He is an insane necromancer that makes his home somewhere near the lake. I had a feeling he would try to get his hands on the staff. That is why I came out here. I must inform Kazen of this turn of events and you must destroy that decrepit fool, Ronaiar. If you find the staff, give it to Geboron.")
		eq.set_global("NecroPre", "1", 5, "F")
		eq.unique_spawn(51155, 0, 0, 1010, 2690, -23, 0)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
