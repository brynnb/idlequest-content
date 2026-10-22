# Existing Lua source reconciliation

## Outcome

This is a disposition audit of **213 existing Lua sources**, not a claim that 213 quests were missing.

- **10 standalone later/inactive sources proposed disabled**, with original bodies retained and no NPC data changed: five Shaman Skull steps 6–8 actors; Samatansyn; Dionna; three sole-purpose Tynnonium actors.
- **Two bounded behavior repairs**: avenging caitiff requests depop after the complete fang pair; Crusader Quarg now explicitly awards both the Mystic cudgel and next-stage chest through bridge-supported calls. Quarg was an additional assignment and is not included in the 213 total.
- **11 unchanged documented substeps/services**. The audit does not certify their complete acquisition chains or undocumented numerical values.
- **24 existing-chain review references**, of which 18 have an exact source-key reference in the inspected review artifacts. The other 6 are explicitly only chain-owner references, not verified actor coverage.
- **121 later-family/source-context records retained pending admission review** and **46 unresolved records**. These are not counted as missing P99 quests and are not mass-disabled based on lexical absence.

All counts and per-source explanations are in `review-records.json`. `manual-dispositions.txt` is the concise manually reviewed source-specific assessment. Its classifications distinguish positive exclusion evidence, later-family context, mixed sources, unresolved identities, documented services, and actual implementation gaps.

## Changes and evidence

- `../p99-source-scope-disables.json`: ten source-only disables. Each row is disabled and its Lua begins with `-- enabled: false`; the remaining body is byte-for-byte unchanged. Explicit P99 evidence is required for every disable. Classic Shaman Skull steps 1–5 and Shackle of Steel remain intact; mixed Whistling Fists lore is not blanket-excluded.
- `../p99-source-caitiff-depop.json`: a single documented lifecycle call, with unchanged reward 5408 and retained 5000 XP. The XP magnitude is not presented as P99-proven.
- `../p99-sz-quarg-alias.json`: amended with owner coordination, preserving the existing phrase correction and 100000 XP. The pinned bridge accepts `itemid`, not an `items` array. Chest 17035 belongs to preserved Skull step 4, not the excluded later chain.
- `evidence-catalogue.json`: exact cached source URLs, timestamps and SHA256 hashes.
- `public-evidence.json`: bounded public search-index evidence, including the exact Tynnonium exclusion excerpt. Search crawl age is distinguished from retrieval date; no fresh wiki/API or exhaustive live-category claim is made.

The review searched and hash-verified **all 8,911 cached P99 pages**, not just 1,135 quest pages. `source-navigation.json` records full-name matches. `item-evidence-navigation.json` adds 597 item-name/numeric-actor search patterns over all page bodies and titles. Both are navigation artifacts only. Names, item rows, hashes, family matches and missing search hits are not semantic parity or absence proofs.

Examples where that distinction matters:

- P99's `Exterminator VII` page actually names VIII, but does not document the rat-leg exchange.
- Numeric 81182 maps to `an_Iksar_slave`, and P99 documents Steel in Droga as well as conflicting Frontier Mountains prose; NPC pages identify 81164 and warn about wrong variants. The exact admitted actor remains unresolved.
- Grobb Bregna duplicates the belt/Spirit Pouch branch that P99 assigns to Kaglari and also contains Aid Garuuk. No whole-source disable or numerical retune follows from that overlap.
- Drake Mountainstorm's Fire Emerald exchange is positively documented on the public item page even though the original lexical quest scan missed it.
- Beastlord, berserker, later-epic and newcomer-armor contexts are distinguished from admitted P99 quests. No baseline enabled flag establishes runtime admission, and intentional product adaptations must be reviewed before any broader scope removal.

## Validation

`runtime-assertions.json` contains **44 hash-bound scenarios** using `tools/p99-lua-runner.go`, pinned source normalization and the actual vendored `items.lua`, with strict mocked APIs. `runtime-results.txt` records 44 passes. This includes 26 proposed active/disabled-source checks plus 18 baseline checks (one defect reproduction and unchanged-substep checks; see exact manifest counts rather than interpreting the label as a full-chain test).

The Quarg baseline reproduction consumes the accepted pair and awards XP while producing neither item; the proposal awards both. Tests cover valid, partial, wrong, extra and repeated offers, preceding-note preservation, low-level/class neutrality and an injected nonfriendly source guard. Actual IdleQuest friendly-faction adaptation is preserved; the injected negative-faction fixture does not imply players encounter that gate.

Caitiff tests prove only that complete fangs request a depop and rejected offers do not. Calling the script twice can still reward twice in a mock; this deliberately does **not** claim real depop, respawn timing or replay protection. Disabled historical Lua is directly evaluated for compilation and rejection behavior only. Disabled metadata is separately checked in `scope-receipt.json`; executing its body does not establish admission.

`file-hash-reconciliation.json` records the correction of three initial CRLF-normalized hashes. All 213 baseline hashes now bind exact file bytes; LF-normalized content hashes are separately labeled. The baseline files were not changed, and the focused integration hash check passes.

`proposal-validation.txt` records syntax/proposal checks. `runtime-receipt.json` binds the successful 44-case result to the current fixture, runner, source normalizer, helper and assertion hashes. `scope-receipt.json` verifies source hashes, row/header consistency, retained disabled bodies, unchanged baseline sources, and zero NPC-row modifications. These checks do not prove real inventory settlement, rollback, full acquisition paths, spawn/death progression, random probabilities or rendered UI behavior.

## Reproduction

From the repository root, run:

1. `python changes/p99-source-review/scan_sources.py`
2. `python changes/p99-source-review/scan_item_evidence.py`
3. `python changes/p99-source-review/build_proposals.py` (also updates the authorized Quarg proposal and its source bindings)
4. `python changes/p99-source-review/build_tests.py`
5. Build `../tools/p99-lua-runner.go` from `validator/` with the official Go toolchain and execute it with `/tmp/p99-source-review-runtime-input.json` on stdin.
6. `python changes/p99-source-review/build_review.py`, then `python changes/p99-source-review/build_ledger.py`
7. Run the three proposal checks and the parent suite.

No immutable baseline, policy file, separate game repository, commit, remote branch, PR or deployment was modified by this reviewer. Broader era/admission questions remain explicit rather than silently presented as complete P99 parity.
