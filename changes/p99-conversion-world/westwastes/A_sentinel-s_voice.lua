-- name: A_sentinel-s_voice
-- Source: sources/projecteq/westwastes/A_sentinel-s_voice.pl
-- Source SHA256: ec28bc1fb9819214e68411006312641230776518c42d77cfb1b54872220f5b2a
-- P99 conversion review: changes/p99-conversion-world/closure-review.json
-- Exact invisible trigger120116 at placement26697; use its authored640s respawn.
-- Preserve full30-unit XYZ bounds and source wording. No P99 timing claim.
local warned = false
function event_spawn(e)
  local x, y, z = e.self:GetX(), e.self:GetY(), e.self:GetZ()
  eq.set_proximity(x - 30, x + 30, y - 30, y + 30, z - 30, z + 30)
end
function event_enter(e)
  if warned then return end
  warned = true
  e.self:Emote("invades your thoughts: 'Beware mortal!  This land is marked by Veeshan, and is sacred to her brood.  None but Dragonkin are welcome here.  Your life is forteit if you proceed.  Ignore this message at your peril!'")
  eq.depop_with_timer()
end
