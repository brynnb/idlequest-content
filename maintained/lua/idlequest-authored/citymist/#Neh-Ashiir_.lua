-- Authority: P99 Shaman Epic Quest, Woe and Envy: Neh attacks immediately
-- after accepting the ring. This is the hostile replacement (90181), not
-- the hand-in NPC (90184). Spawn events carry the authoritative quest owner.
function event_spawn(e)
	eq.attack(e.other:GetName())
end
