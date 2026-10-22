# S-page quest facet review

This review records 65 substantive page/source comparisons. The keyed ledger has 105 entries, including the separately requested Wenbie check. No previously screened-only S title remains without a substantive record. The other entries retain their earlier item/redirect triage or component/partial review status; they are not upgraded to parity.

## Isolated proposals

Fourteen `changes/p99-sz-*.json` proposals contain 26 quest-source changes and four recipe-row changes. The immutable data, effective Lua and maintained Lua baseline were not edited.

- Advertised dialogue aliases: Alex McDarnin, Gardern, Zand, Quarg and Dovan.
- Bloogy: both meat alternatives require two seaweed and one fish egg.
- Semkak: Golden Tablet deterministically rewards Book of Strategy; ambiguous scroll pool preserved.
- Eight sentries: documented +1 / -1 / +1 faction changes. Xyrin uses a six-minute timer and current coordinates, with persistent scalar closure state preventing normal duplicate completion.
- Sornita: later-era tome continuation removed; classic gold/parchment exchange preserved.
- Smaka and Duriek: only explicitly documented faction magnitudes corrected.
- Sarkis: numeric class 5 avoids the specific `Shadowknight` versus runtime `Shadow Knight` spelling mismatch. The broader claim that all legacy string class comparisons are broken was retracted: actual source normalization rewrites them to `GetClassName`. Veetra was not changed.
- Shaman Skull: four documented combines enabled; the explicitly no-fail Ton Warrior Totem combine gets `nofail=1`. Other metadata and components remain unchanged.
- Shaman Epic: lesser spirits allow repeated gems until expiry; Butcher uses its documented five-minute lifetime. Both Freeport greater spirits prioritize the full completion phrase over generic Heyokah. Tower Sentinel returns the three books, which belong to the separately verified pond Sentinel.

## Evidence and tests

`ledger-records.json` is keyed by exact wiki title and contains verified facets, explicit unresolved work, cached evidence hashes, exact source hashes and current proposal hashes. `hash-sidecar.json` provides the same provenance separately. `supporting-data-evidence.json` records exact recipe/components, Sentinel identity/placement, faction names and runtime-reference hashes. `item-name-evidence.json` is a lookup aid, not proof that every numeric occurrence is an item or that a whole quest matches.

`behavior-cases.json` has 43 passing isolated cases with proposed file paths; the Sarkis baseline reproduction is explicitly not proposed-source coverage. The tests use the pinned item helper and actual source normalization but mocked game effects. They do not establish server transaction settlement, the live timer scheduler, movement, UI, encounters or loot acquisition. The local cases cover all 26 modified sources, including both Bloogy meat alternatives, each missing component, the old wrong bundle, repeated valid offers and surplus cash. The parent's final shared suite remains necessary. `proposal-validation.txt` records the individually completed checks. The redundant sequential validation loop was stopped by request (exact session 3060, exit 130); final validation of the frozen set is delegated to the parent combined proposal. Do not infer all 14 proposals passed from this partial log.

Actual reference bridge closure restoration and its `TestLuaHelperStateAcrossFreshEvents` test justify Xyrin's persistent scalar state; this review does not pretend that isolated same-VM calls prove fresh-event persistence independently. Existing item decay is retained as an undocumented fallback.

## Important open gaps

- Spider Legs is absent from Sentry Kale; reward odds and raw XP/faction values are not specified, so no speculative branch was added.
- Storm Giant Toes lacks Kcor's documented branch; exact XP remains unknown.
- Shiny Rings lacks documented XP; Shakey's Stuffing lacks documented cash and faction effects, with no exact amounts to invent.
- Sky tests still simplify away the request/book-return step and omit old-item upgrades.
- Epic encounters, drops, item stats and complete acquisition chains remain unverified. Kirn lacks a documented positive faction effect whose exact magnitude is unknown. Pond Sentinel's final negative faction and many raw XP values are not independently documented.
- Many smaller records retain exact numerical, reward-distribution, recipe, location or lifecycle gaps. Consult each record instead of interpreting this summary as exhaustive parity.
