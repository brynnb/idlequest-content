-- P99 Cleric Epic Quest: the dragon continues the hostile human's encounter.
function event_spawn(e)
	eq.attack(e.other:GetName())
end
