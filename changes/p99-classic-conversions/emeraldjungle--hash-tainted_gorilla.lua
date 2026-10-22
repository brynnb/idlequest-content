-- name: #tainted_gorilla
-- Exact hashed NPC variant; do not overwrite existing plain-name maintained source.
-- P99 tainted gorilla spawns corrupted gorilla on death.
function event_death_complete(e)
    eq.spawn2(94140, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
end
