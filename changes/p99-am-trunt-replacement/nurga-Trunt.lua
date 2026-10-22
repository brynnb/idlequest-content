-- Authored from P99 Monk Epic Quest and retained owner-scoped replacement pattern.
-- Trunt (107161) is spawned only by the sleeping ogre hand-in.
-- The replacement receives the authoritative quest owner in event_spawn.
function event_spawn(e)
    eq.attack(e.other:GetName())
end
