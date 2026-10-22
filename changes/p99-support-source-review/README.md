# Complete-source closure of lexical support buckets

## Result and interpretation

The frozen assignment contains **1,079 enabled, non-policy quest-source keys and 884 distinct source hashes** from the two old lexical labels `world_dialogue_or_support_no_literal_reward_calls` and `name_mentioned_requires_mapping_not_proof_of_review`. All assigned complete bodies were read, with exact duplicates identified explicitly. A name mention or lack of literal reward calls is not evidence of semantic quest review.

`review-records.json` is the unified per-key ledger. It binds the frozen source hash, complete-body review artifact and JSON pointer, current in-memory proposal-overlay hash, source disposition, correction ownership and limits. This is **source-classification coverage, not a claim that all quests, dialogue, numeric values or live gameplay match P99**.

The seven new support proposals correct 90 assigned sources and two separately authorized Beastlord controllers:

- 66 original sources: exclusively later-era task/epic/event hooks disabled through persistent source headers, historical callbacks retained.
- 24 original sources: bounded functional corrections, not wholesale rewrites.
- 2 extra controllers: `emeraldjungle/Scout_Vyrak`, `permafrost/Scout_Janomin`, separately declared and fully read.
- No NPC, loot, ordinary spawn, item or baseline rows changed by this work.

## Deterministic partitions

|Artifact|Assigned keys|Distinct bodies|Scope|
|---|---:|---:|---|
|`world-effect-review.json`|314|217|Effects, services, combat/lifetime consumers, mixed classic/later bodies; local indirect helpers traced|
|`lifecycle-review.json`|216|212|Spawns, signals, dispatch/loaders; nine full encounter-loader dependencies|
|`dialogue-review.json`|312|260|Complete prose-body inspection, concrete quest/crafting leads, direct bounded comparisons; not lexical parity|
|`named-review-dispositions.json`|237|204|Includes 65 reward-bearing sources; existing exact reviews, direct comparisons, unresolved evidence separated|

Distinct-body counts overlap between partitions, so they must not be summed to obtain the global 884 hash count. Assignment ordering and duplicate groups are in `assignment.json`; this frozen input is not rewritten when corrections change source hashes.

## Proposals and tests

|Proposal|Rows/sources|Result|
|---|---:|---|
|`p99-support-world-scope`|36|Task-only impression books and positively traced later epic/event helpers disabled; complete original callback bytes retained|
|`p99-support-mixed-hints`|2|Only Paladin 2.0 hail hints removed from Fayfear/Highmoon, both complete classic combat callbacks and enabled state retained; say metadata synchronized|
|`p99-support-ocean-fishing-scope`|1|Only positively documented Paladin 1.5 fishing trigger removed; entire classic Strongbox handler retained byte-for-byte|
|`p99-support-lifecycle-scope`|22|Exclusive later loaders and positively traced quest helpers disabled|
|`p99-support-lifecycle-values`|3|Ancient croc respawn 16m30; Moldmaster 3 sporelings; tar goo 2 children; original random outcome boundaries/other behavior retained|
|`p99-support-named-fixes`|21|14 mail sender reachability/faction fixes, Tabien name interpolation, Granin unmatched-item return, five later-only source disables|
|`p99-support-dialogue-fixes`|7|Grynnaf missing hail, Jaxxtz later Skull 6 hints removed, Kragia later guide and two Beastlord helpers and two controllers disabled|

Named 117, lifecycle 36, dialogue 15 and mixed-guard 4 and classic strongbox 4 isolated pinned-Lua-VM scenarios pass. These are mocked/static scenarios, **not gameplay, quest settlement or UI tests**. `world-scope.test.mjs` additionally verifies complete-body preservation, source admission headers, all 314 effect-key hashes and mixed-guard preservation. All seven proposals now pass full standalone CLI checks. The lifecycle worker's earlier split-stage receipt remains an honest historical snapshot; final full reruns are in `lifecycle-scope-final-validation.txt` and `lifecycle-values-final-validation.txt`. The system `/usr/bin/go` is not the Go compiler; successful checks use the already-installed `/tmp/p99-go-toolchain/go/bin` with writable cache/module paths. No validator was weakened.

`runtime-assertions.json` is the central-suite-compatible manifest: **217 scenarios bound to all 92 current proposed files**, comprising 68 disabled-body callback-shape/forced-load-only cases and 149 focused functional scenarios. It uses `proposedFile`, `sourceSha256`, `setupExtra` and `assertions`; the disabled cases do not call retired quest callbacks or claim activation. `runtime-manifest-receipt.json` records successful execution against current files, the central fixture and actual items module. Include only this combined manifest in the central list, not the named submanifest again.

## Evidence and important open limits

- `public-era-evidence.json`: official EverQuest task-system and Omens Epic 2.0 dates, official Sony Berserker announcement. Local exact global/item/NPC dependency proof is required in addition to era labels. A high item ID, NPC exclusion flag or missing wiki name is not sufficient.
- `prior-source-reconciliation.json`: exact detailed artifact/hash reuse. Additional worker-specific reconciliations are embedded in their reports. These preserve the original reviewed facets and limitations rather than upgrading an entire source to parity.
- `lifecycle-review-open-quest-chains.json`: 22 exact remaining dependency/era identities with recorded investigation and limits. Cazic revamp versions, Ariam bridle chain and mixed Rinmark/shackles are not blindly disabled.
- Xantis recharge has only a cached discussion question rather than authoritative confirmation. Granin's ration-healing values lack independent P99 documentation. Bruax armor/staff and Cazic's mixed Whistling Fists facet remain unresolved, not numerically guessed.
- Librarian Kesler has positive evidence that books should be given, but exact four topic-to-item grant mapping remains unsupported. No guessed grant was added. Ten cultural recipes remain individually unverified.
- The Spirit of Rage source lacks the leading`#` present in NPC 94126, and the inspected dispatch lookup does not remove it. Its later-source suppression is explicitly preventive/orphan cleanup, not proof that the original hook ran.
- Coldain actor routes, timing and guard combat remain documented imported choreography, not exact new P99 claims. Historical header references to unavailable upstream docs were not treated as inspected evidence.
- Mixed `oot/player` preserves the complete classic strongbox ground-spawn handler. Its separate later fishing callback was removed only after positive original October 2004 Paladin 1.5 player walkthrough/log evidence and exact local flag/item/NPC tracing. No strongbox coordinates or lifetime were guessed. Dynamic-zone doors, Shadowrest service, VP access gates, source combat spells and certain lifetime numbers retain scoped unknowns.

## Reproduction

`reconcile_final.mjs` discovers and merges all current proposals **in memory** through the repository merger, checks assignment/review hashes, rejects unexplained source drift, and refreshes `review-records.json`. It does not apply proposals or mutate the central ledger. `build_world_scope.mjs`, `build_mixed_hints.mjs`, `build_ocean_fishing.mjs` and `build_world_review.py` reproduce the owned artifacts. Child-specific generators/tests are retained beside their evidence.

Baseline remains immutable. No commits, push or PR were performed by these reviewers.
