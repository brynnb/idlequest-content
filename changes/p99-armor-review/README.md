# Eleven N–R Velious armor source reviews

Scope is exactly the Necromancer, Paladin and Ranger Kael/Thurgadin/Skyshrine pages and Rogue Kael/Thurgadin pages. All eleven cached quest pages, eleven associated cached NPC pages and complete current effective Lua handlers were read. Canonical maintained copies match their effective sources. Recursive proposal discovery found no earlier proposal touching these quest rows or sources.

## Bounded corrections

The format-1 `proposal.json` changes seven existing maintained Lua sources and their matching quest rows, without changing identities, enabled states, requirements, quantities, rewards, XP, faction deltas or hand-in behavior:

- Bjarorm Mjlorn: request three crushed topaz rather than one, matching the explicit checklist and existing hand-in.
- Lorekeeper Zorik: identify Torn Enchanted Silk Wristband and Pantaloons correctly, remove a stray opening quote, and restore documented completion speech/emote.
- Battlepriest Daragor: identify Corroded Plate Greaves correctly and restore documented completion speech/emote.
- Gragek Mjlorkigar: identify Ancient Tarnished Chain Bracer instead of a nonexistent chain wristguard.
- Barlek Stonefist, Argash and Foreman Felspar: restore documented completion speech/emote.

No other source changes are proposed. Nalelin's quoted “bracelet” and Kelenek's shortened bracer wording occur in the cached wiki itself; they remain documented naming discrepancies rather than silently rewritten supposed P99 quotes.

## Evidence and artifacts

- `page-review.json`: array of eleven substantive manual facet records, compatible with the I–L review shape. Each contains `title`, `review_level`, `full_cached_page_read`, `page_purpose_classification`, `source_branch_audit`, `sources`, `reviewed_facets`, `component_reward_check`, `adaptations`, `unresolved`, and `verification`.
- `ledger-records.json`: title-keyed ledger records. Every page remains `partial`, with `match_status=source_facets_reviewed_numeric_and_live_parity_open`.
- `evidence.json`: exact evidence and table-input hashes plus all 77 independently checked armor/gem/reward exchanges. The earlier structural component audit was independently corroborated against actual wiki checklists, item records and complete Lua hand-in branches, not treated as full behavioral proof.
- `overlay-inspection.json`: recursive proposal-discovery snapshot, including root-level proposals. No pre-existing quest/source overlap.
- `runtime-assertions.json`: source-hash-bound standard scenario array, using `proposedFile` for changed sources and `file` with `coverageKind=baseline_verification` for unchanged sources.
- `run-tests.mjs`: isolated runner using the existing `tools/p99-test-fixture.lua`, unchanged actual `items.lua`, pinned gopher-lua and pinned source normalizer. GetRaceName is extended only as a capture-fixture value for the supported race-name display API.
- `runtime-receipt.json` and `.log`: all 368 scenarios pass, including 237 proposed-source cases and 131 unchanged-baseline verification cases.
- `verify-evidence.mjs` and `static-check.log`: independently recheck all eleven full-page/source hashes, 77 checklist/item/source exchanges, table fingerprints and dialogue-only trade diffs.
- `proposal-check.log`: format-1 CLI validation passes for seven rows and seven sources.
- `final-ownership-check.json`: at the final 331-proposal snapshot, no overlapping ownership and the complete in-memory proposal merge succeeds (576 rows, 499 sources).
- `freeze-receipt.json`: final package fingerprints.

## Deliberate adaptations and unresolved limits

Friendly quest-faction access is preserved. Actual faction effects are not bypassed. The intended class and armor equip restrictions do not automatically establish a hard hand-in class predicate, so the existing generated no-class-gate behavior remains unchanged. The individual pages' level 45/50 infobox entries conflict with the cached Velious Class Armor page's explicit statement that there is no level requirement; no level gate is added.

All 77 exchanges require one armor component plus three identical gems and produce exactly one reward. The four-slot handler accepts a complete set in one offer, calls return_items on every path, and has no persistent multiquest credit. Isolated checks cover incomplete and unrelated offers, exact counts, retained coin, repeated offers and dialogue reachability. They do not prove actual inventory settlement, rollback, live NPC selection, acquisition, persistence, multiquesting, rendered UI or a connected playable chain.

The four named faction directions on the Thurgadin pages and Paladin Kael page match current Lua. Other assigned pages mention faction generically and do not prove each recipient. No assigned quest page establishes exact XP or faction magnitudes, so all current numbers remain uncertified fallbacks. The numeric faction entries on NPC pages concern killing the NPC and must not be misused as armor turn-in rewards. No cash is documented or granted; omission is not a measured P99 zero.

NPC identity/static placement candidates are retained, including same-name Skyshrine variants and later Kaelshard NPCs. Later-zone duplicates are not treated as classic Kael actors, and `exclude=1` alone is not interpreted as a live availability verdict. Static placement rows do not establish zone policy, selection, navigation or rendered height.

## Integration requirement

These maintained armor sources were generated by `scripts/quests/velious-armor.mjs`. The authoritative generator and dialogue inputs are absent from this content export. Before regenerating in the game repository, synchronize the seven reviewed dialogue corrections into those inputs. This proposal intentionally preserves generator provenance and does not modify immutable upstream sources, maintained/effective baselines, data tables, reference files or manifest.

The parent owns central ledger/test-manifest integration and final combined validation. No commit, push, PR, merge, deployment or production action is performed by this review.
