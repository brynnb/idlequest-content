-- Converted from ProjectEQ Perl quest script.
-- Source: oot/player.pl
-- items: 13860

function event_enter_zone(e)
	local qglobals = eq.get_qglobals(e.self)
	if qglobals["strongbox"] ~= nil then
		eq.create_ground_object(13860, -9200, -430, -293, 0, 3000000)
		eq.delete_global("strongbox")
	end
end

function event_fish_success(e)
	local qglobals = eq.get_qglobals(e.self)
	if qglobals["paladin_epic"] == "3" or qglobals["paladin_epic"] == 3 then
		if tonumber(e.fished_item) == 69914 then
			e.self:Message(1, "As you reel in the dark fish's scale, you notice a large fish in the water")
			eq.depop_all(69141)
			eq.spawn2(69141, 0, 0, -9169, 265, -20.5, 460)
		end
	end
end
