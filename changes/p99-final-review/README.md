# Independent safety and correctness review

Reviewed read-only in the native cloud checkout, against baseline `b717b8a5c5dc5bd779d160b534c10329c1ae04bc`, on 2026-10-22. No tracked baseline, source, proposal, or implementation file was edited by this reviewer. No `AGENTS.md` was present in the checkout or its applicable parent directories.

## Scope and result

Discovery used `findProposals` and `mergeProposals` from `tools/p99-merge-proposals.mjs`, with manifest primary keys, not the stale combined proposal. The latest input receipt contains 326 component proposals, 548 changed rows and 486 source targets. `review-inputs.json` binds the component/source bytes to a timestamp and aggregate fingerprint. Other workers were still updating the set; this review is not a release freeze or final parity certification.

The review inspected the opening full merged inventory and source-delta surface (313 proposals, 517 rows, 470 source targets), then concentrated on reward delivery, newly used APIs, event ordering, changed recipes and registered container routes, exclusion preservation, epic adaptations, and test/report semantics. Subsequent focused manual checks included the Noxhil, Nekexin, Eldreth, Tax Box, old-Sky upgrade, Garzicor hostility and ground-availability deltas. The larger final inventory receipt is not a claim of fresh deep review of every concurrently arriving source. It did not manually certify every path in every script against every wiki page. No additional definite newly introduced runtime defect was established in that scope. The concrete compatibility blocker found below was addressed during this review.

## Concrete blocker found and resolved

The reviewed presence originally staged spawned-corpse `AddToHateList` and source `eq.depop()` in the same event. The pinned `reference/server/internal/quest/deferred_runtime_apis.json` explicitly rejects source-depop hate combinations. This was pre-existing, not introduced by the timer correction. It was reported and then corrected in the authoring stream: `changes/p99-tz-garzicor-ghostly-presence/necropolis--#a_ghostly_presence.lua` now stages only the spawn and depop; `changes/p99-tz-garzicor-corpse-spawn/necropolis--#Garzicor-s_Corpse.lua` adds the established owner-scoped `event_spawn` / `eq.attack` pattern. The corpse's existing death-to-wraith handler and all activation fields remain unchanged. The exact known incompatible batch has been removed. Complete live lifecycle and transaction settlement are still not verified. This reviewer did not edit the encounter.

## Independently observed checks

- `npm run validate`: passes, 36,496 files and 53 tables. Manifest SHA256 `8bd2b042870b4e7e46141b811ed12e1a9dee453dcf03f2e07f06fccd4cc3e205`; tracked diff remains empty.
- An earlier run passed all ten targeted merge, recipe-structure, container-compatibility and audit-integration tests. The last rerun, during further authoring, passes nine and fails only source-overlay reconciliation for `airplane/Dugaas_Helpyre` because the derived report is stale. Log: `static-checks.txt`. Regenerate that report after freeze and rerun; this is not a green final aggregate receipt.
- Literal reference audit: 3,879 item/faction references checked, none missing. Dynamic expressions and acquisition are not covered. Log: `reference-check.txt`.
- Current source-review baseline digests all reconcile. The earlier Margle digest error, missing recipe expectations, and stale source-overlay report were corrected during this review.
- The behavior manifest initially failed before execution because three baseline Sky cases lacked a recognized source category. The importer now distinguishes baseline verification from proposed-source coverage. The fresh behavior run passes all three Node checks and 1,198 isolated Lua scenarios after that fix. It includes 94 baseline reproductions, which are not proposed-source coverage. Source hashes bind the exercised versions in `behavior-receipt.json`; see `behavior-check.txt`.

The late Sky, Garzicor and ground-availability deltas were manually inspected after the behavior run loaded its cases; that run must not be represented as runtime coverage of later additions. Checks ran during concurrent changes. The final coordinator must regenerate aggregate reports and rerun validation/tests after the proposal set stabilizes.

## Important bounds on interpretation

- Container reconciliation now covers 146 reviewed recipes, of which 18 have a definite `no_registered_allowed_container` blocker. The other 128 have static registered routes only. A registered container that rejects a recipe through its curated allowlist is not a valid route; the checker correctly evaluates both registration and allowlisting. New enabled recipe rows do not make blocked recipes playable.
- The 18 blocked recipes are 9638, 9676, 9697, 9710, 9724, 9766, 9767, 9809, 9835, 9865, 12811, 13000, 13004, 27829, 9776, 9783, 9792 and 9797. This is snapshot-specific, not a permanent whitelist.
- Existing `must_learn` high-bit values such as 48 are not automatically manual-learning gates; the reviewed runtime distinguishes low-nibble manual-container behavior from the advanced interface. Do not misclassify these values solely because they are nonzero.
- The enabled-overlay regression guards against unsupported `QuestReward({items=...})`; the reviewed corrected multi-item outputs use explicit `SummonItem`. VM mocks still do not establish transactional inventory settlement, rollback, delivery of actor effects or real UI behavior.
- Scalar Lua upvalues and normalized `Class()` string comparisons are supported in the actual bridge. They are not defects merely because a simplified reader would overlook serialization/normalization.
- Trunt's newly authored event-spawn owner attack follows a supported scoped pattern; that is not evidence of live encounter completion. Druid epic timers, owner-oriented encounter adaptations, simplified Sky starter summoning, and existing exclusion policy were not blanket replaced with literal P99 mechanics.
- Broad coverage of 1,135 cached titles and 3,431 original P99-zone sources is classification and reconciliation, not full quest parity. The 213 source-review dispositions explicitly retain numerical, acquisition, recipe and lifecycle limits. Newly added old-Sky exchanges implement documented item mappings only; unknown XP, cash, faction and despawn effects remain unknown rather than verified zero.

No commit, publication, merge, or deployment was performed.
