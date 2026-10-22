# Remaining trade-surface review

This closes the bounded structural inspection of the 129 original P99-zone
sources assigned as `unmapped_trade_no_literal_reward_calls_requires_inspection`.
`review-records.json` contains one exact-key, exact-current-source-hash record per
assigned source, the frozen assignment/hash list, source-specific findings,
related review links and retained uncertainty. No source proposal or immutable
baseline was edited.

## Result

All 129 `event_trade` bodies are strictly refund-only: 128 call the shared items
return helper, and Watchman Grep calls `ReturnHandinItems` directly. Every complete
source was inspected, including its other callbacks and helpers: 48 distinct
complete-source hashes, 833 unique-source lines, 1,638 lines including duplicates.

Whole-source context is deliberately separate:

- 89 dialogue/emote sources.
- 8 scripts containing only the refund handler.
- 9 quest-hint or conditional-dialogue sources, with limitations retained.
- 10 soulbinding-service sources.
- 3 ambient patrol/conversation callback sources.
- 2 world-combat callback sources.
- 8 non-trade progression/lifecycle sources requiring separate scope/context
  reconciliation, not a new hand-in implementation.

Those eight are Gimlik starters/escort `cazicthule/48040` and `/48254`, Brettaru
Tyco, Guard Gregor, Bruiser Noz, Silithis Sisnta, Assistant T-os and Grex. Existing
Gimlik endpoint/tracker, Shaman Skull and Scout Blade artifacts are linked where
relevant. Related-family coverage is not falsely counted as exact callback
coverage. Guard Gregor's cached NPC page explicitly marks him DNE/delete and
identifies a June 2002 introduction; the actor's admission was not modified.

## Verification boundary

`validation.json` verifies all assigned keys and full-source hashes against the
current merged proposals. All 129 match and remain unmodified. The shared return
helper, bridge compatibility method, consumption calculation and the two reached
flavor-signal receivers were checked for context.

This is not a full dialogue/wiki audit, a claim of P99 numerical parity, or proof
of live actor admission, inventory settlement, encounter execution or UI behavior.
No game/runtime tests were run. Harmless flavor is retained. Future reuse must
match each record's exact source hash; source edits require reinspection.
