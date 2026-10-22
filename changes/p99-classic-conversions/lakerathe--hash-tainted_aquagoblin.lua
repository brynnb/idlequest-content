-- name: #tainted_aquagoblin
-- Exact hashed NPC variant, preserving existing plain-name Lua separately.
-- P99 Druid Epic; ProjectEQ implementation preserves spawn coordinates and API.
function event_death_complete(e)
    eq.unique_spawn(51149, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
end
