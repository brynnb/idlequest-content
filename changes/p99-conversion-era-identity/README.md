# Era and identity closure

Reviewed the complete preserved sources for exactly the 25 `root_era_identity` assignments.

- **1 full conversion:** Bidils the Quickhand, all 14 independent dialogue branches and emotes, with player-name/race substitution and safe unmatched-item refunds. No GM-event reward, coin hand-in, NPC activation, or spawn change is invented.
- **21 positive later-era dispositions:** Accursed Temple revamp encounters, Shaman/Rogue 1.5 dependencies, the identified 2006 holiday chains, and Stiggles' LDoN chain.
- **1 exact event-scope disposition:** Kithicor jack-o-lantern, whose 19 placements require `peq_halloween`. This does not classify the classic Unrest jack-o-lantern as later content or assert an unsupported introduction date.
- **2 actual transport/registration blockers:** North Ro and Iceclad boat proximity markers. Numeric NPC lookup is supported, but normal registration, transfer settlement, and the intended P99 boat adaptation are not established.

The 22 excluded sources remain unchanged Perl-only rows. No empty Lua substitutes, authoritative scope-policy edits, or NPC activation changes are proposed. The separate classic Shakey pumpkin exchange is preserved.

## Review artifacts

- `closure-review.json`: exact assignments, complete-source dispositions, identities, source hashes, evidence bindings, and explicit limitations.
- `data-evidence.json`: complete public baseline rows, canonical row hashes, shard hashes, and line locations for the reviewed NPC/spawn/item/loot/spell edges.
- `external-evidence.json`: public evidence URLs and cache dates, access limitations, and minimal compatibility conclusions. Private implementation excerpts and private repository metadata are deliberately excluded; compatibility conclusions are not presented as publicly reproducible runtime tests.
- `stiggles-delegated-evidence.json`: the earlier trade review's public quest identification, clearly distinguished from a fresh retrieval by this reviewer.
- `../p99-conversion-era-identity.json`: Format 1 full-row/source proposal for Bidils only.
- `runtime-cases.mjs`: shared builder for the same 17 Bidils assertion bodies used by the standalone and central suites. Run it directly to deterministically regenerate `runtime-assertions.json`.
- `runtime-assertions.json`: current proposed-file/source-hash bindings and the minimal race fixture extension, consumed by the central suite without embedding a duplicate fixture or item module.
- `test-receipt.json`, `focused-test.log`, `isolated-test.log`, `central-integration-test.log`, and `proposal-check.log`: actual validation receipts.

## Validation

Run with a Go toolchain on `PATH`:

```sh
node tools/cli.mjs check-proposal . --proposal changes/p99-conversion-era-identity.json
node --test changes/p99-conversion-era-identity/behavior.test.mjs
```

The focused suite checks the exact 25 assignments and all public bindings, caller/loot/spell/event identities, and 17 isolated Lua scenarios. It also verifies the central manifest matches the shared builder and re-executes the same 17 scenarios with the central loader’s fixture-extension ordering. Both fixture arrangements use the public fixture and actual item-refund module. `P99_GO_BINARY` can select a Go compiler; the cloud run used the already-installed toolchain.

These are source/schema/syntax and isolated-script checks, not live gameplay, database settlement, natural NPC availability, GM-event reward progression, boat transport, multiplayer, or rendered-UI verification. Cached P99 pages retain their original retrieval dates; no fresh P99 access is claimed where live retrieval failed.
