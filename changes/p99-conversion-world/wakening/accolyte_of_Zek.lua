-- name: accolyte_of_Zek
-- Source: sources/projecteq/wakening/accolyte_of_Zek.pl
-- Source SHA256: 9c5f437671e4002b172cc30c8619161054ea7241a67c8209740e85a2c3ea1810
-- P99 conversion review: changes/p99-conversion-world/closure-review.json
-- Velium Focus cleanup receiver. Phenocryst signals these quest-spawned actors;
-- retain unconditional signal cleanup and no synthetic rewards.
function event_signal(e)
  eq.depop()
end
