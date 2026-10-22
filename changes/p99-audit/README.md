# P99 evidence audit and Lua proposals

This is a best-effort, evidence-backed **content proposal**, not a claim that every P99 quest is playable or every undocumented value is exact. The immutable export is unchanged. No server migration, deployment, live database write, or change to the separate game repository was performed.

## Scope and results

- Inventory: **8,043 exported quest rows**; **3,431 original rows** in the declared **121-zone** Classic/Kunark/Velious audit corpus. The zone names are bound independently to public exported rows in [scope-provenance.json](scope-provenance.json). Scope membership does not establish the era or admission of individual quests.
- Evidence: **1,135 cached quest-related pages**, comprising **954 source-facet reviews** and **181 page-purpose/scope classifications**. None is left merely screened or unreviewed. Facet review is not a complete gameplay certification. See [review-coverage.json](review-coverage.json).
- Original missing Lua: **499 rows**, of which **127 now have proposed Lua**: **123 enabled rows** and **4 retained-disabled rows**. The package also introduces **15 separate quest/helper rows**, including three legacy zone aliases. These are script rows, not completed quest counts.
- Every original missing-Lua row has an explicit final disposition. The initial 73 conversions were followed by 51 conversions from 124 further feasibility reviews, plus three separately authorized disabled caller variants. Six translations are deliberately partial flavor/refund implementations; cosmetic and encounter limitations are separately labeled.
- Existing Lua receives source-, quest-, and evidence-bound corrections. A full-body review of 1,079 formerly unclassified support sources is linked separately from historical page records. Later-era admission and remaining chain/identity uncertainties have dedicated final followups rather than being silently marked complete.

The exact **372 rows still without Lua** are:

| Disposition | Rows |
|---|---:|
| Positive later-era or excluded-event evidence | 256 |
| Empty source/handler | 15 |
| Proven alias or superseded implementation | 20 |
| Retained explicit policy or unsupported variant | 40 |
| Genuine quest-progress runtime/policy blocker | 2 |
| Ambient, world, transport, or dungeon-contract gap | 27 |
| Unresolved era or identity | 8 |
| Placeholder without a proven quest | 4 |

[Conversion closure](conversion-closure-report.md) and its [machine-readable report](conversion-closure-report.json) retain every exact key, source hash, evidence pointer, partial-conversion label, and limitation. [Source coverage](source-coverage.json) distinguishes fresh full-source reviews from historical page links and lexical discovery leads.

## Known incomplete paths, not hidden conversions

Four genuine P99 quest families retain concrete content/runtime/policy blockers:

1. **Broodmother escort**: Erdarf's converted source remains disabled; complete escort choreography is not established.
2. **Crest of the Fauns**: the bag's damaging explosion and ground-rubble settlement cannot safely be substituted; Shamus remains disabled.
3. **The Velium Focus**: helper/caller translations do not establish the full procession/encounter, and the caller remains disabled.
4. **Reinforcements for the Tunarean Regiment**: helper translations preserve the disabled caller/reward policy and do not establish full choreography.

The two direct no-Lua blocker rows are part of this four-family set; they are not two additional quests. The 27 ambient/world gaps are **not** automatically blocked quest rewards. In particular, Kalayia lacks documented roaming parity, not demonstrated quest-loot access; the Charasis helper conflicts with P99's temporary wing-key contract, not a proven missing entrance-key reward.

Other limits remain separate:

- **18 of 154 reviewed recipes** have an attested downstream container-registration block. This repository cannot safely repair that runtime registry. The other 136 have no reported registration block, which is not proof of craftability. See [container-compatibility.json](container-compatibility.json).
- Librarian Kesler is a positively identified P99 missing-book-grant candidate, but the exact topic-to-item mapping is unproved. The Krup watcher event's exact era remains unresolved. Xantis's recharge identity and replacement-item compatibility are corroborated, but live settlement/denomination behavior is not certified.
- The three final source followups reconcile **194 distinct keys**: 151 new full-body-preserving later/event disables, 10 mixed-source exclusions, two previously owned exclusions, two documented unchanged services, and **29 explicit unresolved mappings/scope questions** (including Kesler). See [final-source-closure.json](final-source-closure.json). This is a bounded followup count, not a count of every undocumented value. Uncertain existing Lua is preserved with explicit evidence limits in `p99-final-admission`, `p99-final-chain-closure`, and `p99-final-uncertainty`. Absence of a wiki page is not positive later-era evidence.
- When exact XP, faction magnitude, reward probability, timer, or acquisition data is undocumented or conflicts, existing values are preserved and labeled rather than invented.

## Compatibility and evidence boundaries

The P99 cache is a dated, hash-verified snapshot, not a claim of live wiki freshness. Public evidence links and exact source/page hashes accompany the findings. Imported scripts are fallback evidence, never silently promoted to P99 authority. Private implementation source, registry definitions, and document excerpts are not bundled; limited compatibility conclusions are explicitly attestations rather than publicly reproducible current-runtime proof.

Intentional engine adaptations remain visible, including friendly quest-faction eligibility, epic 1.0 level-gate policy, existing Sky shortcuts and selected player-local encounter approximations. Actual faction deltas and documented rewards remain independently reviewed. Suggested wiki levels are not automatically hard gates. `npc_types.exclude=1` is not equated with an actual quest ban.

Some sources are generated externally. [generator-sync.json](generator-sync.json) records synchronization requirements; this package does not change those generators or authorize regeneration outside this repository. Baseline files, data primary keys, and exclusion policy are not relaxed to make a proposal pass.

## Apply one proposal set, not both

`changes/p99-combined-audit.json` is the consolidated Format 1 proposal. Components preserve focused histories. Apply the combined proposal **or** selected components, never both against the same export. Use the repository's handoff workflow; do not overwrite immutable files with proposed sources.

Regenerate current reports and the combined proposal from the repository root:

```sh
node tools/p99-quest-inventory.mjs . --write
node tools/p99-build-ledger.mjs .
node tools/p99-review-coverage.mjs .
node tools/p99-resolution-report.mjs .
node tools/p99-source-coverage.mjs .
node tools/p99-conversion-closure-report.mjs .
node tools/p99-final-source-closure.mjs
node tools/p99-container-compatibility.mjs .
node tools/p99-merge-proposals.mjs .
node tools/cli.mjs check-proposal . --proposal changes/p99-combined-audit.json
npm test
```

The merger rejects conflicting complete rows, source preimages, and manifest identities. The actual CLI checks source-target policy and Lua metadata; merely running the `tools/proposal.mjs` module does not validate a proposal.

## Verification meaning

Tests include byte-bound inventory/evidence checks, proposal preimages, strict isolated Lua behavior, source compilation, item/recipe references, complete declared row links, policy preservation, and public-artifact privacy checks. See `tools/p99-runtime-tests.md` and the final-validation receipts for input fingerprints and exact results. Intermediate receipts are historical diagnostic snapshots, not proof of the latest bytes.

Disabled later-era callbacks are retained for review. Missing item literals already present in such historical bodies are reported separately from newly introduced or active unresolved references; they are not presented as valid P99 rewards.

Isolated execution does **not** prove inventory settlement, transaction rollback, concurrent multiplayer behavior, natural actor populations, client rendering, live pathing, or complete acquisition chains. The optional MySQL integration test is skipped without a configured scratch database. The full game runtime is not included. Use a verified official Go toolchain for the test harness, not an unrelated executable named `go`.
