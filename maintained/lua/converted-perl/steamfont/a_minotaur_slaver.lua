-- Converted from ProjectEQ Perl quest script.
-- Source: steamfont/a_minotaur_slaver.pl
-- P99: https://wiki.project1999.com/Hero_Bracers_Quest

function event_death_complete(e)
	if math.random(0, 99) >= 94 then
		eq.unique_spawn(56152, 177, 0, -1294, 1360, -103, 0) -- NPC: Minotaur_Hero
	end
	e.self:Say("I die soon! Meldrath, help me!")
end
