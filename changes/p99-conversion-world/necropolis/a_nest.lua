-- name: a_nest
-- Source: sources/projecteq/necropolis/a_nest.pl
-- Source SHA256: 2304985dd59954a33b8ad6a1beeb2b971ca6987d2ed1ef0ffe23ed42b144d466
-- P99 conversion review: changes/p99-conversion-world/closure-review.json
-- P99 confirms triggered beetles. Six offsets and trap lifecycle are retained
-- ProjectEQ details, not verified P99 counts. Duplicate aggro cannot duplicate a wave.
local triggered = false
function event_aggro(e)
  if triggered then return end
  triggered = true
  local x, y, z, h = e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()
  eq.spawn2(123132, 0, 0, x, y, z, h)
  eq.spawn2(123132, 0, 0, x - 2, y, z, h)
  eq.spawn2(123132, 0, 0, x + 2, y, z, h)
  eq.spawn2(123132, 0, 0, x, y - 2, z, h)
  eq.spawn2(123132, 0, 0, x, y + 2, z, h)
  eq.spawn2(123132, 0, 0, x + 1, y + 1, z, h)
  eq.depop_with_timer()
end
