-- Converted from ProjectEQ Perl quest script.
-- Source: eastkarana/Dark_Elf_Corruptor.pl

function event_spawn(e)
	eq.set_timer("despawn", 300000)
end

function event_timer(e)
	eq.stop_timer("despawn")
	eq.depop()
end

function event_combat(e)
	if e.joined then
		eq.stop_timer("despawn")
	else
		eq.set_timer("despawn", 300000)
	end
end

function event_death_complete(e)
	eq.stop_timer("despawn")
end
