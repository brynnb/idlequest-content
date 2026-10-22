-- name: a_sifaye_defender
-- Source: sources/projecteq/wakening/a_sifaye_defender.pl
-- Source SHA256: ff2b66f1c424dade3f12bd6c14323db5f744b894374eb1e8f4766be55cb29066
-- P99 conversion review: changes/p99-conversion-world/closure-review.json
-- Preserve randomized NPC-versus-NPC aggression and300-second lifetime.
-- NPC spell list10 requires a version5-ready scene; no attack is replaced by flavor.
function event_spawn(e)
  eq.set_timer("leave", 300000)
  local target = eq.ChooseRandom(119166, 119167, 119168, 119169)
  -- EQEmu does not attack an absent target. Avoid the current runtime's
  -- unsupported deferred-empty-hate batch when a chosen giant has died.
  if eq.get_entity_list():GetMobByNpcTypeID(target).valid then
    eq.attack_npc_type(target)
  else
    e.self:Say("I am unable to locate NPC type " .. target)
  end
end
function event_timer(e)
  if e.timer ~= "leave" then return end
  eq.stop_timer("leave")
  eq.depop()
end
