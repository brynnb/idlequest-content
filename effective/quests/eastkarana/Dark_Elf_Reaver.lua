-- Converted from ProjectEQ Perl quest script.
-- Source: eastkarana/Dark_Elf_Reaver.pl

function event_spawn(e)
	eq.set_timer("despawn", 600000)
end

function event_timer(e)
	eq.stop_timer("despawn")
	eq.depop()
end

function event_death_complete(e)
	eq.stop_timer("despawn")
end
