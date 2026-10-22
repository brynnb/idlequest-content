# Lifecycle and world-support source review

## Result

All **216 assigned current Lua bodies** were read, with hash-bound per-key dispositions in `lifecycle-review.json`. There are **212 distinct byte hashes**: five Necropolis splitting sources are identical and are explicitly grouped, not hidden or counted as five independent implementations.

- **22 exclusive later-era/custom hooks and loaders** are disabled by `../p99-support-lifecycle-scope.json`. Each original complete body is preserved under a two-line disable header; no NPC data is changed.
- **3 documented values** are corrected by `../p99-support-lifecycle-values.json`: ancient croc respawn **16m30s**, Moldmaster **3 sporelings**, and large tar goo **2 children**. Probabilities and other behavior are not guessed.
- **10 exact-key, exact-hash prior reviews** are reconciled: four version-0 City of Mist reavers, five tainted druid hooks, and Sabnie's Taxes dialogue context. Approval is reused only for the relevant facet, not the whole source.
- **9 encounter loaders** and all their resolved full bodies were examined. `zone_assistance`, `thread_manager` and `aa_box` were read. Five later/custom loaders are disabled; ring_war and berserkerepic_1_5 resolve already-disabled encounter rows; trumpy and motg remain intact.
- **36 isolated Lua cases pass**, plus structural/hash assertions. These use the pinned GopherLua runner with mocked APIs, not the private game runtime.

## Not a blanket P99-completion claim

Twenty-two sources retain unresolved quest-chain identity/era. Other records explicitly retain unproved probabilities, pathing, timings, key-boss spawning, combat parameters and dialogue details. The main-source bodies are not unread; the gaps are dependency identity and direct P99 behavioral evidence.

High-risk open groups include the Blackened Tree/Limb chain, Goblin contest, Northern Ro haunt chain, Western Karana werewolf/Shady chain, Rathe Sphinx servants, Warsliks goblinmaster, Cazic revamp bosses. The exact 22 open keys are also listed separately in lifecycle-review-open-quest-chains.json. A bounded follow-up positively closed all four Afflicted coven actors, the rogue package guard event and the decomposing-body/Fatestealer helper; those six are included in the 22 disables.

Befallen's excavator/foreman chain leads to Sir Ariam's Ghostly Bridle story. The cached **The Burning Dead** is a different Opal/Marnek quest and cannot certify it. Timorous Rinmark support is not disabled merely because another later shackle exists. Mixed `fearplane/a_scareling` keeps classic signal behavior; its Berserker-only death branch is an explicit bounded future candidate.

`npc_types.exclude=1` is never treated as a quest-source ban. A zone loader plus an enabled encounter row only establishes callback admission in the reference server. It does not prove that the NPC spawns, that the callback executes in a running game, or that loot/transactions settle correctly. The disabled historical Perl initiators used to identify later chains are not asserted to execute.

Generated comments reference `docs/frozenshadow-progression.md`, `docs/coldain-ring-nine-audit.md` and `docs/coldain-quest-chains.md`, none exported here. These were **not** presented as inspected proof. Cached wiki metadata are preserved by reference and do not claim live freshness.

## Artifacts and checks

- `lifecycle-review.json`: all 216 per-key records, source SHA256, body evidence pointer, exact prior-facet references, dependency resolution, limitations and proposed final hashes.
- `lifecycle-review-dependencies.json`: full 9 encounter bodies, 3 shared modules and positively traced additional sources, each hash-bound.
- `lifecycle-review-public-evidence.json`: official era facts, the contemporaneous Druid 2.0 checklist used for the crippled-wurm identity only, and the indexed primary Rogue 1.5 prequest walkthrough (direct fetch unavailable).
- `lifecycle-review-proposed.json`: exact 25 changed keys and before/after hashes.
- `lifecycle-review-test-cases.json` and `lifecycle-review-test-results.json`: 36 source-bound isolated cases and receipts.
- `lifecycle-review-test.py`: verifies assignment/hash coverage, body preservation, ten prior artifact hashes, and focused Lua behavior. Uses existing `/tmp/p99-ranger-lua-runner` built from repository `tools/p99-lua-runner.go`.

Validation: all proposal schema/preimage/source stages passed in full CLI runs; the syntax stage initially encountered an incorrect default Go executable, then all 25 sources passed the repository syntax validator with the existing Go toolchain. See `lifecycle-review-validation-results.json`. The all-proposal overlay merge has no conflicts; see its hash-bound snapshot receipt. No live gameplay test is claimed.

No baseline files, existing proposals, NPC rows, shared ledger or tools were modified. No commit, push or PR was performed by this review.
