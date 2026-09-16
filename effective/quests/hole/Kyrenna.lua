-- P99: Shadow Knight Epic Quest, cached 2026-07-17.
-- Caradon's Cell Key hand-in releases both attackers. The imported script
-- relies on native EQ NPC aggression, which does not initiate this encounter
-- in IdleQuest. Use the shared, owner-scoped spawn event and attack lifecycle;
-- do not look up another NPC by type or fabricate a combat/loot result.
function event_spawn(e)
	eq.attack(e.other:GetName())
end
