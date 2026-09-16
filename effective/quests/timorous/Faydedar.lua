-- Converted from ProjectEQ Perl quest script.
-- Source: timorous/Faydedar.pl

function event_spawn(e)
	if eq.get_entity_list():IsMobSpawnedByNpcTypeID(96073) then
		eq.depop()
	end
end
