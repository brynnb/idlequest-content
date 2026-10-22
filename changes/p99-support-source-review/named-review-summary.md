# Named support-source reconciliation

## Result

All **237 assigned exact source keys**, including all **65 literal reward-bearing sources**, have complete source-body reads and SHA-256-bound dispositions in `named-review-dispositions.json`. This is **not** a claim of 237 fully P99-verified quests. NPC-name mentions were treated only as discovery hints; exact quest-source identity and reviewed facets are recorded separately. `npc_types.exclude=1` was never used as a quest ban.

## Bounded proposal

`changes/p99-support-named-fixes.json` contains **21 source/quest-row changes** and no NPC/world rows:

- Fourteen postal senders: restore reachable advertised interest/mail/delivery choices, accept the documented destination links and full delivery requests, and show destinations for ambiguous multi-route `deliver`. Lislia's previously unhandled mail link now explains the documented courier system. No invented destinations or XP values.
- Ton Twostring: P99-documented faction deltas +5/+1/+1/-1/-1. Preserve independent delivery receipts, existing recipient adaptation, 100 XP and 8–12 gold pending exact numeric evidence.
- Tabien: interpolate the player name rather than emit the literal `$name`.
- Granin O'Gill: repository-standard unmatched-item return only. Preserve the one-Iron-Ration predicate and spell 200; P99 documentation does not establish their historical parity.
- Five exclusive later-era sources disabled at source level, with the entire original body retained: `oot/#Kaiaren`, `burningwood/Atheling_Plague`, `burningwood/Clerk_Doval`, `lakeofillomen/Klok_Sargin`, `southkarana/#Azibelle_Spavin`. These have positive Monk Epic 2.0, post-fifth Shaman Skull, or Druid Epic 1.5 dependency evidence. South Karana Azibelle is not the Qcat Badge quest actor.

The parent proposal `p99-support-world-scope` owns the task-only `lakeofillomen/a_bloodgill_goblin` correction. Its exact current proposal row and resulting source hash are bound in this ledger; it was not edited here.

## Evidence and tests

- Exact existing substantive references are resolved to 56 JSON pointers. Seventy-seven cached-page evidence entries were SHA-256 checked. The complete per-source record retains behavior, selected facets, source identity, adaptations and remaining limitations.
- **117 isolated Lua behavior cases pass**, including all postal destination/link forms, independent and combined Ton receipts, wrong-item return, Tabien interpolation, and Granin valid/invalid/extra/repeat trades. Against the assigned pre-fix source bodies, 40 of the same assertions pass and 77 fail as expected.
- All 21 complete before-rows match immutable baseline rows; all proposed file/row hashes agree; all five disabled bodies are suffix-identical to their original bodies. No NPC rows changed.
- The in-memory merge check passes across the 343 proposals, 680 rows and 601 sources at the final merge-check snapshot. This does not write or apply a combined artifact. See `named-review-merge-check.json` for its proposal-hash binding.
- Mocked handler tests do not certify the game bridge, inventory settlement, live world behavior or timer scheduling. Final standalone proposal-validation receipt is `named-review-proposal-validation.json`.

## Important remaining limits

- **Cazic Thule is mixed**: its classic boss lifecycle/combat coexists with the Gandan/Tynnonium Whistling Fists quest branch. Existing source-level scope evidence positively identifies the related later chain, but wholesale source disable would destroy classic behavior. That quest facet remains untouched and needs a separately scoped decision/correction; it is not certified as P99.
- **Xantis recharge**: complete source and relevant NPC/item/Ring of the Dead/Thex Mallet pages were checked. The public P99 talk page contains a question, not confirmation of the recharge or 10-gold cost. Existing values remain unverified.
- **Granin healing**: NPC/head quest pages and aliases do not establish the ration/spell exchange. A source-derived external example is not independent P99 corroboration; only return safety was changed.
- **Bruax armor/staff**: exact Shrine of Bertoxxulous Enchanter/Magician/Wizard ledgers already identify and remove later training referrals. The NPC page is skeletal and does not document the armor/staff recipes; no unsupported numeric correction or NPC ban was made.
- Canonical-vs-alias limitations remain explicit for frontier Droga Regal Band actors, Ruathey, Marl and other similarly named source variants. Later mixed Mayor Gubbin facets were not resolved by disabling classic content.
- Exact quest numbers absent from P99 documentation, existing routing adaptations, full combat/spawn parity and unreviewed dependency behavior are not inferred from names or successful Lua parsing.

Priority follow-up facts and searched aliases/pages are in `named-review-priority-followup.json`. `named-review-evidence.json` is a discovery index, not independent proof of semantic review. No commit, push or PR was made.

## Deterministic disposition totals

- bounded_fix_proposed: 15
- bounded_safety_fix_with_p99_facet_unresolved: 1
- documented_adaptation_reconciled: 1
- exclusive_later_source_disable_proposed: 5
- exclusive_later_source_parent_proposal: 1
- existing_exact_facet_review_reconciled: 34
- existing_specific_facet_prose_reconciled: 13
- later_facet_pending: 1
- mixed_source_later_facet_pending: 1
- mixed_source_unresolved_quest_facet: 1
- noncanonical_alias_compared_not_certified: 6
- selected_p99_facets_compared: 26
- selected_p99_facets_with_difference: 1
- selected_p99_facets_with_gap: 1
- selected_p99_facets_with_unknown_numbers: 3
- source_behavior_read_no_p99_parity_claim: 121
- unresolved_alias_quest_facet: 4
- unresolved_quest_facet: 2
