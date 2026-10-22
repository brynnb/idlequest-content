-- name: Bloodpriest_Ioukond
-- Source: sources/projecteq/wakening/Bloodpriest_Ioukond.pl
-- Source SHA256: 1c7d7fda1dab12df81c65272c56df0bd743fe1fdc91c4c1f5e61165495c4cae6
-- P99 conversion review: changes/p99-conversion-world/closure-review.json
-- Velium Focus cleanup receiver. Phenocryst signals these quest-spawned actors;
-- retain unconditional signal cleanup and no synthetic rewards.
function event_signal(e)
  eq.depop()
end
