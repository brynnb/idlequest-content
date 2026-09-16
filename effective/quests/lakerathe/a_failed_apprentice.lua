-- Source: ProjectEQ lakerathe/a_failed_apprentice.pl (death replacement).
-- P99 Necromancer Epic Quest: the replacement attacks after the golem dies.
-- Use the quest-owner-aware attack operation, not deferred numeric hate.
function event_spawn(e)
	eq.attack(e.other:GetName())
end

function event_death_complete(e)
	eq.spawn2(51144, 0, 0, -921, 210, 72.3, 62) -- a_tortured_soul
end
