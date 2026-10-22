-- enabled: false
-- P99 scope: Only death signal for Taskmaster Mirot cleric_epic>=4 Wayfarer event; Taskmaster source explicitly identifies Cleric Epic 1.5. Historical body retained below.
function event_death_complete(e)
	eq.signal(57150,1); -- NPC: Taskmaster_Mirot
end

 