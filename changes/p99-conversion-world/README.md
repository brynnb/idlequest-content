# World and quest-helper conversion closure

## Result

The proposal adds **24 Lua sources**: 21 of the49 assigned legacy sources plus 3 separately authorized Wakening caller/reward variants. All 3 caller/reward variants remain disabled, matching actual baseline quest policy.

The 49 original sources are individually reviewed in `closure-review.json` with source hashes, evidence hashes, concrete compatibility conclusions and final dispositions:

- 21 translated, including 3 explicitly cosmetic-runtime-limited callbacks.
- 13 superseded by specific existing named controllers/adaptations, not inferred from missing documentation.
- 15 unconverted: 12 world/encounter/dungeon-contract rows and 3 era-uncertain Sleeper population chains.

No unconverted row is established as a direct blocked P99 hand-in or reward dependency. Kalayia's source is only roaming; her quest-associated loot does not turn missing roaming parity into a blocked quest. The Charasis master-key helper conflicts with P99's documented temporary per-wing-key contract; it is not asserted to be a missing P99 quest.

Two quest families still cannot be called complete: **The Velium Focus** and **Reinforcements for The Tunarean Regiment**. Their 7 assigned helpers are translated, but the 3 authorized caller/reward sources remain genuinely disabled and retain documented encounter gaps. These 10 source rows are not the 15 unconverted rows.

## Scope and fidelity

- Numeric source helpers are reconciled against the existing name-first controller adaptations and every composed top-level proposal. No duplicate proposal rows were found.
- Supported actor grids, timers, signals, cleanup, spawn coordinates, rewards and hate changes are retained. Source bugs in timer names and repeated trap triggering are corrected with focused checks.
- Perl and Lua signal delays both use milliseconds. Literal 300ms signals remain 300ms. Timer seconds are independently converted to milliseconds. The official EQEmu source and its hash are recorded in `evidence/signal-units.json`.
- The Ring5 messenger uses the exact existing grid233 through the owner-scoped executor. This is an explicit private-patrol adaptation, not shared-world patrol parity.
- Sleeper local callbacks do not implement the blocked downstream shared/cross-zone world event. Cosmetic illusion/appearance intent is retained even where display delivery is unsupported.
- No source was excluded merely because a P99 page is absent. No classic odds, NPC identities or missing paths are invented.
- Current implementation was inspected read-only. Private source, documentation, repository paths and revision metadata are not redistributed. Public baseline references and minimal compatibility conclusions are sufficient to understand the proposed changes, not to claim live execution.

## Validation

`node tools/cli.mjs check-proposal . --proposal changes/p99-conversion-world.json`

Actual CLI result: 24 rows and 24 sources validated. `cli-validation.txt` is the raw command result.

`node changes/p99-conversion-world/run-tests.mjs`

24 focused isolated Lua scenarios pass. The manifest `behavior-cases.json` is compatible with the central `tools/p99-content-behavior.test.mjs` fixture, includes exact source hashes, and tests actual authored Lua plus the repository item-hand-in library. Mocks are not server delivery evidence.

`node --test changes/p99-conversion-world/static.test.mjs`

Five static checks bind all 49 originals, three extensions, proposal/source/case hashes, exact NPC identities, complete authored grids, door leaves, spell-list capabilities, reward/quest loot, disabled policy and known superseding controllers. Static expectations are in `static-expectations.json`.

Use the repository's official Go toolchain/cache environment when building the isolated runner. No live server or end-to-end encounter execution was performed.
