-- P99 scope: later Paladin 1.5 fishing trigger removed; classic Journal Strongbox handler preserved.
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

