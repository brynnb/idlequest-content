-- Authority: P99 Shaman Epic Quest, final encounter: Rak attacks immediately
-- after accepting the Child's Tear. This is the hostile replacement (90183),
-- not the hand-in NPC (90174). Do not rely on ambient faction aggression.
function event_spawn(e)
	eq.attack(e.other:GetName())
end
