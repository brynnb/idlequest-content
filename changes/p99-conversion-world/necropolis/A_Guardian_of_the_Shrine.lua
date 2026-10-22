-- name: A_Guardian_of_the_Shrine
-- Source: sources/projecteq/necropolis/A_Guardian_of_the_Shrine.pl
-- Source SHA256: 9f328b0917089fdad1b9840cf42e45c44552607adf2e7c8426d7d4b6e324d62b
-- P99 conversion review: changes/p99-conversion-world/closure-review.json
-- Zone-local invisible trigger123124 provokes Jaled Dar123011. Preserve hate,
-- not a warning-only substitute. Same-name Skyshrine actor114508 is unrelated.
function event_spawn(e)
  local x, y = e.self:GetX(), e.self:GetY()
  eq.set_proximity(x - 7, x + 7, y - 7, y + 7)
end
function event_enter(e)
  local guardian = eq.get_entity_list():GetMobByNpcTypeID(123011)
  if guardian.valid then guardian:AddToHateList(e.other, 1) end
end
