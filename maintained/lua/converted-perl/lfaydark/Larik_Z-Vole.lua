-- Converted from ProjectEQ Perl quest script.
-- Source: lfaydark/Larik_Z-Vole.pl

function event_trade(e)
	e.self:ReturnHandinItems(e.other)
end

function event_death_complete(e)
	eq.unique_spawn(59159, 83, 0, -1150, 1930, 0, 0) -- a dark elf courier
end
