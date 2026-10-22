# Initial coherent snapshot validation

Snapshot: `/tmp/p99-validation-20261022T055845Z`.
This is an interim, reproducible snapshot, not certification of the final source-closure set.

- npm: 33 passed, 0 failed, 1 optional database-integration skip.
- Five nested suites: 13 passed, including 19 classic VM scenarios.
- Main VM: 1,802 passed. Correct classification is 1,484 proposed-source cases, 223 unchanged-baseline verifications, and 95 baseline reproductions. The raw receipt misclassified ten original helper cases; `misclassified-baseline-cases.json` preserves the exact correction.
- Flavor VM: 167 passed. Main plus flavor coverage accounts for all 509 proposed Lua sources.
- Standalone armor: 368 passed; independent evidence checks matched 77 exchanges. Paladin: 45 passed and three recipe structures checked. These standalone cases overlap main-suite coverage and must not be added as unique cases.
- Central static recipe oracle: 154 expectations passed. Forty-five declared static links on proposed rows passed. Proposed literal Lua reference scans found no missing IDs; broad unchanged-baseline lexical diagnostics are not clean and are preserved without calling them introduced regressions.
- Immutable baseline: all 36,496 files and 53 tables validated; no tracked immutable-baseline changes.
- Raw full Lua census: 8,577 of 8,578 inputs compiled. The sole failure is the pre-existing disabled Perl utility at `effective/quests/utility/comments-helper-generator.lua`, baseline quest row 12299. All 509 proposed Lua sources compiled.

## Combined-proposal result and subsequent fixes

Initial combined validation failed on enabled/header consistency for Erdarf Restil and Tiam Khonsir. Their rows were disabled while their source headers defaulted to enabled. The original snapshot and failed logs remain unchanged.

The parent subsequently added explicit disabled headers and refreshed bindings in the active checkout. Both actual CLI component validations passed with no input drift; all nine focused behavior cases passed. See `active-fixed-components.json` and `active-fixed-component-behavior.json`. This does not replace a final whole-set snapshot validation.

The initial snapshot used baseline directory symlinks, which the validator correctly rejected. Per-file hard links replaced them without changing file bytes or weakening validation. They are used read-only by task discipline, not kernel read-only mounts. The obsolete layout errors remain in the logs.

## Reproduction and proof

`input-fingerprints.json` binds the coherent copied inputs. `prepared-input-fingerprints.json` binds the regenerated reports and combined proposal actually tested. `run-status.json` records commands, durations, exits, log hashes, and superseded layout checks. `proposed-source-proof.json` binds source coverage. `receipt.json` contains the detailed initial snapshot result and limits. `artifact-sha256.json` hashes this artifact set.

Environment:

    PATH=/tmp/p99-go-toolchain/go/bin:$PATH
    GOCACHE=/tmp/p99-go-cache
    GOPATH=/tmp/p99-go-path

Main commands, from the snapshot root:

    P99_TEST_RECEIPT=/path/to/receipt.json npm test
    node --test changes/p99-classic-conversions/*.test.mjs changes/p99-conversions-velious/coverage.test.mjs changes/p99-audit/inventory.test.mjs changes/p99-sky-timer-review/static-expectations.test.mjs
    node changes/p99-armor-review/verify-evidence.mjs
    node changes/p99-armor-review/run-tests.mjs
    node changes/p99-paladin-epic-review/test-review.mjs
    node changes/p99-paladin-epic-review/test-recipes.mjs
    node tools/cli.mjs check-proposal . --proposal changes/p99-combined-audit.json
    npm run validate
    node tools/p99-reference-check.mjs .

Full raw compilation is recorded by `run-driver.py` and `compile-input-fingerprints.json`. Do not rerun drivers that point at the active checkout unless intentionally validating a new set.

No database transaction, live bridge, inventory settlement, crafting, pickup, world activation, acquisition, rendered UI, or full playable-chain success is established. No commits, push, deployment, or baseline edits were performed.
