-- P99 Cleric Epic Quest: the Seeker's transformation attacks the giver.
-- Use the shared owner-scoped spawn/attack lifecycle, as for SK Kyrenna.
function event_spawn(e)
	eq.attack(e.other:GetName())
end
