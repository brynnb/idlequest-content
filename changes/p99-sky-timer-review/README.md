# Plane of Sky class starter respawn review

Review date: 2026-10-22. Bounded to all 14 class starters and their exact static spawn chains.

## Result

Proposal: `changes/p99-sky-starter-respawn.json` (format 1). Exactly 14 `spawn2` rows change only `respawntime`; 13 change from 640 to 10,800 seconds, and Josin Faithbringer changes from 640 to 28,800 seconds. Existing zero variance, placement, membership, spawn weights, scripts, rewards, and policies are preserved.

| Class | Exact NPC ID / name | Group | Spawn2 row | Before seconds | Proposed seconds |
| --- | --- | ---: | ---: | ---: | ---: |
| Bard | 71042 / Cilin_Spellsinger | 2091 | 2687 | 640 | 10800 |
| Cleric | 71052 / Josin_Faithbringer | 5482 | 2697 | 640 | 28800 |
| Druid | 71043 / Strandar_Pinemist | 5473 | 2688 | 640 | 10800 |
| Enchanter | 71049 / Enchanter_Jolas | 5479 | 2694 | 640 | 10800 |
| Magician | 71050 / Magus_Frinon | 5480 | 2695 | 640 | 10800 |
| Monk | 71046 / Holwin | 5476 | 2691 | 640 | 10800 |
| Necromancer | 71053 / Drakis_Bloodcaster | 5483 | 2698 | 640 | 10800 |
| Paladin | 71037 / Dason_Goldblade | 2087 | 2679 | 640 | 10800 |
| Ranger | 71054 / Ranger_Spirit | 5484 | 2699 | 640 | 10800 |
| Rogue | 71051 / Thalik_Silenthand | 5481 | 2696 | 640 | 10800 |
| Shadow Knight | 71048 / Sarkis_Ebonblade | 5478 | 2693 | 640 | 10800 |
| Shaman | 71044 / Medicine_Man_Veetra | 5474 | 2689 | 640 | 10800 |
| Warrior | 71045 / Torgon_Blademaster | 5475 | 2690 | 640 | 10800 |
| Wizard | 71047 / Wizard_Schrock | 5477 | 2692 | 640 | 10800 |

## Evidence and precedence

- The cached [Plane of Sky Quests (Old)](https://wiki.project1999.com/Plane_of_Sky_Quests_(Old)) explicitly says “Quest mobs have a 3 hour respawn time.” Its introductory section identifies the 14 parenthesized class starters as the NPCs to hail before summoning a turn-in NPC. The exact IDs each resolve to one dedicated 100%-weight spawn group and one static `airplane` row. Their existing scripts summon a tester then call `depop_with_timer`. Applying the general sentence to natural starter respawn is a documented contextual interpretation, not an independent measurement of 14 timers.
- The specific cached [Josin Faithbringer](https://wiki.project1999.com/Josin_Faithbringer) NPC page identifies emulator ID 71052 and the cleric starter, then explicitly says his respawn is 8 hours and prevents back-to-back Sky turn-ins. This exact-NPC description takes precedence over the general 3-hour line, so row 2697 uses 28,800 seconds. The contradiction is retained rather than silently assigning 3 hours to everyone.
- All 14 current class-test pages were read for lifecycle evidence. None states a respawn duration; they must not be cited as independent confirmation of these durations. Exact-ID scanning of the cached NPC pages found five pages for four identities: Dason, Josin, Magus/Magi Frinon, and Torgon. The non-Josin pages give no timer. The two Frinon pages refer to the same emulator ID 71050; no duplicate NPC is created.
- The old-page audit ledger classifies the overview as historical reference because of obsolete reward versions. This is a source limitation, not an actual quest exclusion and not proof that every non-reward statement is obsolete. This proposal restores no old reward. The generic timing claim should be revisited if newer dated exact-NPC evidence is obtained. Source cache paths, retrieval dates, hashes, identities, and conflict details are in `review.json`.

## Preserved adaptations and verification limits

- Direct tester spawning and skipped book-return steps are documented IdleQuest adaptations and remain unchanged. No fast-respawn adaptation was found in the reviewed policy documents.
- All 14 effective starter scripts are enabled, and none is banned by `content_exclusions.json.quests` or the exact/pattern NPC exclusion policy. Their existing `npc_types.exclude=1` flags do not establish a script ban and are not changed.
- Natural starter respawn uses seconds. The coordinating audit verified `seconds-based timer behavior` and uniform plus/minus variance in current game `downstream population service` at revision `reviewed-runtime`. This bounded review did not access a second checkout.
- All 28 class testers are quest-spawned, with no static spawnentry, and their baseline Lua `depop` timers remain 300,000 milliseconds. [The Fiery Avenger](https://wiki.project1999.com/The_Fiery_Avenger) explicitly documents Dirkog and Inte Akera lasting five minutes; this is not a starter respawn period.
- No other room actors, island populations, quests, factions, item rewards, source files, data shards, reference files, or manifest were edited. No commit, push, PR, merge, SQL application, or deployment was performed.
- Static expectation tests and proposal validation do not establish natural elapsed-time behavior, scratch-DB application, or rendered playability. These stages are not run by this bounded review.

## Reproduce the focused checks

```sh
node --test changes/p99-sky-timer-review/static-expectations.test.mjs
node tools/cli.mjs check-proposal . --proposal changes/p99-sky-starter-respawn.json
npm run validate
```

The focused test pins every expected NPC/group/spawn identity, exact full preimages, timer-only deltas, Josin’s specific exception, source hashes, unchanged tester lifetimes and policy, and absence of overlapping independent proposals. Test and validator receipts are adjacent to this file.

Validation result: 5/5 focused static tests passed; proposal validation passed for 14 rows and 0 sources (0 Lua sources needed compilation); baseline validation passed for 36,496 files and 53 tables. The full repository test suite was not rerun by this bounded subreview.
