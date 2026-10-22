# T–Z P99 review receipt

All 223 assigned cached pages have substantive, hash-bound facet reviews. This is not a claim of full P99 parity. Baseline discrepancies and proposed corrections are deliberately separate; read each record's `referenced_proposals` before interpreting an early baseline finding as unfixed.

## Deliverables
- `manual-facet-review.json`: every page, full-page evidence hash, reviewed source hashes, facet findings, explicit gaps and referenced proposals.
- `ledger-suggestions.json`: non-mutating coverage-ledger recommendations. The immutable baseline ledger was not edited.
- `final-receipt.json`: exact proposal/source/row counts and hashes, shared-source references and blockers.
- `test-scenarios.json` and `behavior-tests.txt`: 139 passing, current-source-hash-bound focused cases. They execute through the pinned Go normalizer with real item turn-in helper and mocked world APIs, not the game engine or rendered UI.
- Recipe/ground/Old Sky sidecars preserve exact row evidence, identities, counts and remaining availability limits. `blocked-gift-doll-charges.json` is a recommendation, not an applicable item-table proposal.

## Important limits
Undocumented XP, faction magnitudes, random probabilities, timers and world coordinates are not fabricated. Exact supported corrections coexist with explicitly retained source fallbacks. Enabling a recipe or ground allowlist row does not establish live crafting or pickup. Full epic, encounter and UI lifecycle checks remain separate. Historical `p99_audit` labels are not treated as runtime exclusions; actual `quests` policy exclusions remain intact. Friendly-faction and documented no-minimum-level adaptations remain intact.

The two doll charge edits are blocked by the item table's missing primary key. Geologist's toolkit recipe is absent, Garzicor crafting has missing/ambiguous definitions, Ooga's old hammer identity is unresolved, and Tarton's known no-fail discrepancy and Jaka placement difference remain explicit. Other per-page limits are retained rather than erased by a broad completion label.

No remote writes, deployment or user-computer work were performed. Parent owns combined structural/compiler/runtime validation and any eventual PR.
