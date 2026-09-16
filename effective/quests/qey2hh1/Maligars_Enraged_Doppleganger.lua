-- P99 Bard Epic Quest: the note hand-in creates an attacking doppleganger.
-- The spawn event carries the authoritative quest owner. Keep this on the
-- supported attack path rather than substituting deferred numeric hate.
function event_spawn(e)
	eq.attack(e.other:GetName())
end
