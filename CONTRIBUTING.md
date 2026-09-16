# Contribution workflow

Work one quest or coherent zone correction at a time. Keep original sources and
the exported baseline unchanged; proposals belong in `changes/`. The maintained
IdleQuest tree remains the runtime source of truth. This repo is a review/export
workspace, not a competing runtime that the game reads live.

Every proposal must state:

- Exact zone, NPC IDs, script keys, items and affected table keys.
- P99 page URLs, revision if available, retrieval date and supporting facts.
- Before/after behavior and any disagreement or uncertainty in evidence.
- What is deliberately different for IdleQuest.
- Validation performed: source review, conversion, runtime tests and rendered UI
  tests are separate statuses. Never label a syntax check as a playable quest.

Use the review record template in `changes/README.md`.

## Content policy

- Classic, Kunark and Velious are in scope. Do not use a low numeric ID or an
  imported expansion flag as proof. Existing scope ledgers contain historical
  Classic/Kunark-only decisions; inspect their reasons before extending them.
- Quest-only faction gates intentionally return Ally/max-friendly. Do not add
  faction grinding. Actual faction rewards, world aggression and merchant rules
  are independent. Required items, class/race/level and explicit state remain.
- P99 gameplay evidence takes priority over ProjectEQ implementation details.
  Where evidence conflicts, document a reasonable choice; do not invent exact
  probabilities, coordinates or mechanics and present them as sourced facts.
- Preserve whole loot-table semantics: probability, multipliers, limits, minimum
  drops and level restrictions. An item's `chance` is not necessarily its final
  per-kill probability.
- A quest-created NPC and its ordinary spawn may coexist intentionally, or one
  may need exclusion. Test the actual runtime identity and spawn lifecycle.
- Perl conversion is not a goal in itself for out-of-era or deliberately excluded
  content. An existing Lua correction must not be overwritten by bulk conversion.

## Verification boundary

Use the existing IdleQuest Lua runtime and focused mechanics tests. The reference
Go files document that runtime; they are not a standalone fork. Test hand-ins for
independent alternatives, partial/extra items, repeat turn-ins, rewards, actual
spawn/death transitions and inventory rollback. Preserve unrelated offered items.

Use Docker for IdleQuest Playwright tests. Setup may seed prerequisites, but
actual Give/Hail/Combine clicks and normal combat/death paths must be exercised
when claiming UI verification. Do not require naturally farming rare loot just
to validate a hand-in; do not claim a full acquisition chain from seeded fixtures.

Read `reference/docs/p99-quest-audit-workflow.md` for the current policies. It
supersedes older chronological notes about test preparation.

## Publication

Use the included offline wiki before
requesting pages from P99. Do not upload game assets,
private data or credentials.
