-- name: a_pile_of_bones
-- Source: sources/projecteq/necropolis/a_pile_of_bones.pl
-- Source SHA256: 84496e17e9ca7bee3964ed834a8ed938a64381d3caf152612ba0831efd37006f
-- P99 conversion review: changes/p99-conversion-world/closure-review.json
-- Preserve the local triggered construct123097, corpse-position spawn and trap
-- respawn. Trigger only on entry, not a second time on the ensuing combat release.
-- No new probability is inferred from the P99 description that constructs sometimes appear.
local triggered = false
function event_combat(e)
  if not e.joined or triggered then return end
  triggered = true
  local x, y, z, h = e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()
  eq.depop_with_timer()
  eq.spawn2(123097, 0, 0, x, y, z, h)
end
