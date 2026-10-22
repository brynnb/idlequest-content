-- name: player
-- Source: sources/projecteq/neriakb/player.pl
-- Source SHA256: 08a075501da270fd97ba4f43c0a92d2de942d57578efef49262f9b0e9b04d9c5
-- P99 conversion review: changes/p99-conversion-world/closure-review.json
-- Retain the classic three-leaf Commons gate. Omit only the explicit LDoN
-- Wayfarer invitation, not the classic door handler. No invented key requirements.
function event_click_door(e)
  local door = e.door:GetDoorID()
  if door == 1 then
    eq.force_door_open(2); eq.force_door_open(49)
  elseif door == 2 then
    eq.force_door_open(1); eq.force_door_open(49)
  elseif door == 49 then
    eq.force_door_open(1); eq.force_door_open(2)
  end
end
