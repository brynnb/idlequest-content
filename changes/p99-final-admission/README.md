# Bounded later-content admission closure

This proposal supersedes the pending-admission label for exactly the **121** original records assigned from `changes/p99-source-review/review-records.json`. It does not replace the historical full-source review or modify authoritative quest policy.

## Result

- **110** later-only Lua sources: quest row disabled, explicit `-- enabled: false` header, entire original callback body preserved byte-for-byte.
- **8** mixed sources: exact later branches removed while existing ambient behavior or legacy note handling remains.
- **2** sources already disabled by `p99-support-dialogue-fixes`: Scout Vyrak and Scout Janomin. Their current owner, proposed source and hashes are referenced, not duplicated.
- **1** unchanged, precise ambiguity: Mazziana Ridgerunner. The source consumes classic Orc Scalps for acknowledgement without reward, but neither source nor independent historical evidence establishes its date, task or later caller. No reward is invented and no exclusion is inferred from a missing wiki page or PEQ-derived era metadata.

The proposed changes comprise **118 quest rows and 118 Lua files**, with no additional assignment records, NPC edits, spawn changes or modifications to immutable source/data/reference trees.

## Mixed-source changes

| Source | Removed | Preserved |
| --- | --- | --- |
| Edwardian Holyblade | Truthbringer newcomer kit/molds/weapon | Existing note 18737 to tunic 13554, Ding and 100 XP; initial greeting |
| Ulraz S-Lon | BoneMail newcomer weapon/shield branches | Existing note 18757 to tunic 13586 and 100 XP; greeting and independent Ultricle lore |
| Innkeep Min | Source-marked Halloween 2018 state and scroll exchange | Ordinary hail |
| Artisan Bill Whistletop | Source-explicit DoN cultural patterns and tasks | Existing non-halfling greeting and its original trigger |
| Symbell Sunara | Task 1947 meat consumer | Ordinary hail |
| Kamidra Voragone | Task 154 egg consumer and solicitation | Existing greeting prefix |
| Marthor | Tynnonium/Whistling Fists brew state, timer and hand-ins | Ordinary hail |
| Medron Y-Lask | Ulraz's later shield-support exchange | Entire existing merchant hail/animation callback |

The two legacy guild-note fallbacks are preserved, not newly certified as canonical P99 actor mappings. Cached P99 documentation identifies Valeron Dushire and Nezzka Tolax as the canonical givers. No XP, faction, coin or timing value was invented.

## Evidence and corrected identities

`assignment.json` freezes original keys/hashes and pre-existing owners. `review.json` is the central-compatible 121-record disposition ledger, with an empty `additionalRecords` array. `public-evidence.json` distinguishes current search-index evidence, successfully opened official pages and hash-verified cached P99 pages. `local-evidence.json` binds all 121 public source bodies and explicit item syntax references, plus 17 supporting caller traces. `source-bindings.json` binds the 118 proposed sources and intended maintained targets.

Exact links matter: Trooper Drix is later Warrior Pike #6 support through message 48008 and crown plans 48009, not Beastlord content. Elishia Leafrunner's letters 8969/8970 trace to Jeremy in excluded Jaggedpine. Andara's bow support traces to Selzar's rogue armor family. Alaurin and Vohnkare are Enchanter 2.0; Lythe is the main Rogue 1.5 sequence, not its prequest.

Direct P99 wiki access was unreliable; there is no claim of a fresh exhaustive wiki fetch. Previously denied ZAM access was not retried or bypassed. High item IDs, NPC exclusion flags, names and missing wiki pages are not admission evidence. Only public checkout material and public evidence were used.

## Validation

- Actual repository CLI: **118 rows / 118 sources validated**, zero Lua failures.
- **7 focused static tests**: exact assignment coverage, baseline and caller hashes, proposal/source binding, full-body preservation, mixed retention, ownership and runtime source hashes.
- **137 normalized Lua VM scenarios**: 110 historical disabled-body load/handler checks, 26 mixed-source behavior checks and one unchanged Mazziana baseline capture. All pass using the actual pinned `items.lua` helper and strict mocked APIs.

`runtime-assertions.json` is the central-compatible source-hash-bound manifest. `runtime-receipt.json` records exact inputs and test outputs. Disabled body checks deliberately load retained historical code and **do not prove activation or exclusion by the real game**. Mixed tests do not establish world dispatch, real inventory settlement or UI behavior. This proposal makes no all-quests-playable claim.

Reproduce from the repository root:

```sh
python changes/p99-final-admission/build-review.py
python changes/p99-final-admission/build-local-evidence.py
python changes/p99-final-admission/build-tests.py
node --test changes/p99-final-admission/admission.test.mjs
export PATH=/tmp/p99-go-toolchain/go/bin:$PATH
export GOCACHE=/tmp/p99-go-cache GOPATH=/tmp/p99-go-path
node tools/cli.mjs check-proposal . --proposal changes/p99-final-admission.json
(cd validator && go run ../tools/p99-lua-runner.go < /tmp/p99-final-admission-runtime-input.json)
```

The Go executable used for validation is Go 1.23.12. The default environment's unrelated `go` executable is not suitable.
