-- Authority: P99 Necromancer Epic Quest, Symbol of Testing encounter.
-- The failed apprentice's death creates this exact replacement; it attacks
-- that encounter's quest owner immediately, rather than waiting for a pull.
function event_spawn(e)
	eq.attack(e.other:GetName())
end
