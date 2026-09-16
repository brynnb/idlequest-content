-- Converted from ProjectEQ Perl quest script.
-- Source: steamfont/minotaur_slaver.pl
-- P99: https://wiki.project1999.com/Hero_Bracers_Quest

function event_death_complete(e)
	local random_result = math.random(0, 99)
	if random_result >= 94 then
		eq.unique_spawn(56152, 177, 0, -1294, 1360, -103, 0) -- NPC: Minotaur_Hero
	elseif random_result >= 88 then
		eq.unique_spawn(56161, 0, 0, -2179, 1319, -101.2, 0) -- NPC: Minotaur_Lord
	end
	e.self:Say("I die soon! Meldrath, help me!")
end
