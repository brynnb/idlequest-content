# Sixteen trade-boundary closure review

This proposal adds eight Lua scripts, not eight completed progression quests.
All eight converted trade handlers only return offered items and money. No reward,
XP, cash, faction gain, NPC row, or spawn is introduced.

| Final disposition | Keys |
|---|---|
| Converted full (2) | thurgadina/Fergus_Sawdust; thurgadina/Guard_Dagur |
| Converted partial (6) | iceclad/Joshel_the_Large; skyshrine/Grudash_the_Baker; skyshrine/Ruru_the_Cook; thurgadina/Meg_Tucter; thurgadina/Petcas_Coldbeard; thurgadinb/Loremaster_Solstrin |
| Positively later (5) | necropolis/#an_Odd_Looking_Spider; nro/#Verrell_Cogswin; skyshrine/Mercutius_Del_Torre; skyshrine/Torm_Wenrar; steamfont/#Smith_Numden |
| True runtime block (1) | kael/a_bag_of_supplies |
| Uncertain era/identity (2) | neriaka/Hukulk; neriaka/Ranjor |

## Important boundaries

- Faun supplies requires damaging explosion and ground rubble. Neither omitted
  damage nor direct inventory rubble is an acceptable substitute. The current
  executor rejects legacy selfcast and non-beneficial targeted delivery.
- Dagur preserves exact Baldvin115132 as a separate speaker. No actor is spawned.
- Meg and Solstrin retain lore, not the later eighth-Shawl rewards.
- Ruru and Grudash retain only bounded non-pie flavor. Removed pie exchanges are
  not reintroduced; Grudash's remaining response has no invented initiator.
- Petcas keeps the existing Ronodun115019 responses. Autonomous story initiation
  depends on the separately owned Ronodun conversion. Adia remains the documented
  five-gold souvenir seller; the Special Beans epic1.5 branch is excluded.
- Joshel's bandana branch is unverified, not positively classified later. Only
  the documented hail is retained. Neriak guildmaster aliases are not silently
  substituted for the separately documented Grobb actors.
- Official pinned EQEmu source establishes signalwith delay units as milliseconds.
  Grudash's original numeric delay1 remains1ms, not1000ms. Exact P99 timing remains
  an explicitly identified upstream fallback.
- NPC exclusion flags remain unchanged. These changes do not activate actors or
  prove that any actor is present in a running zone.

## Artifacts and verification

- `../p99-conversion-trades.json`: complete before/after quest rows and maintained
  source insertions with SHA256 bindings.
- `closure-review.json`: all16 original Perl hashes, prior dispositions, final
  statuses, evidence, runtime blockers/support and exact actor expectations.
- `runtime-assertions.json`:38 current-source-bound cases for the central manifest.
- `run-focused-tests.mjs`: standalone execution using the shared strict fixture,
  actual items.lua, and pinned Go Lua VM. Also verifies source/evidence/actor
  bindings and that only Lua plus dialogue metadata differs in each full row.
- `validation.json` and `behavior-receipt.json`: actual CLI and focused-test results.

The official CLI passed8 rows/8 sources; all38 isolated cases passed. These are
mocked script-logic tests, not live game settlement, world lifecycle, timed signal
integration or rendered UI tests.

Authoring reproduction (overwrites only this proposal and its owned artifacts):
`python changes/p99-conversion-trades/build-review.py`, then
`python changes/p99-conversion-trades/finalize-review.py`.
After regeneration rerun both the official CLI and focused tests, and regenerate
validation receipts. No commit, push, PR or baseline mutation was performed.
