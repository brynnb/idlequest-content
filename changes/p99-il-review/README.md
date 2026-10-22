# P99 I–L manual source review

This sidecar reviews all 40 assigned cached pages in full and their complete mapped canonical/alias Lua and Perl branches, with supporting actor, item, loot and recipe evidence where available. Page purpose is kept separate from source-branch coverage. Every record remains `partial`; this is not a full-playability or live-inventory claim.

## Artifacts

- `manual-facet-review.json`: 40 substantive per-title records, source/cache hashes, exact wiki URLs, corrections, adaptations and unresolved limits.
- `ledger-records.json`: matching 40 records for the parent's coverage-ledger integration.
- `static-evidence.json`: compact source/item/actor/loot/recipe candidates and hashed export inputs. Samples have totals and truncation flags. The table snapshot used 234 proposals; later overlays were inspected separately rather than misrepresented as a repeated full table scan.
- `overlay-inspection.json`: final recursive `findProposals` snapshot, including root-level proposals, with 254 proposal hashes. No other proposal overlapped this worker's 14 quest rows or source targets at the ownership check.
- `../p99-il-parity/proposal.json`: 14 narrow existing-Lua corrections, no new quest IDs or activation changes.
- `runtime-assertions.json` and `test-receipt.json`: 33 source-hash-bound focused scenarios, all passing through the existing pinned source normalizer and strict mocked Lua fixture with the actual items module.

## Corrections and retained limits

Corrections cover three Lozani aliases and Dran partial-hand-in safety; Kobl, Toresian, Ziglark and Anrey documented dialogue; Slansin and Perrir explicitly documented faction amounts; Lilkus's documented Heretics increment and fixed one-gold component; Whoopal's silver denomination; Leuz's accept-task branch precedence; and Tiam's documented one-to-four rewards without lifting his exclusion. Perrir's separate guild-note values are unchanged and tested. Lilkus's existing silver/copper amount and armor probability remain explicitly unverified.

Shared Lysbith and Tabure dialogue fixes were coordinated into their owners' existing proposals rather than duplicated. Neb and Jaled parent conversions were independently reviewed. Wenglawks's bounded reviewed Velious override is distinguished from actual Tiam/Breya exclusions. Historical audit labels, expanded zone scope and NPC `exclude=1` do not independently determine runtime availability.

Important unresolved points include the unsolved Legion Lager/Neozite chain, the excluded unfinished Icestar event, the Innoruuk recommendation skullcap faction contradiction, unknown numerical rewards, and the missing effective-illusion-race prerequisite for Wallin. Both exposed race APIs use the base player race in the pinned runtime, so no incorrect base-race-only gate was introduced. Journal Strongbox has ground row 1772, but that row is absent from the exported enabled-ground-spawn allowlist; quest-specific availability remains unverified.

The 33 mocks do not prove inventory settlement, eligibility adaptations, spawned actor lifecycles, activation or UI. The parent owns merged CLI validation. An unrelated shared Leraena quest-row conflict (12097) was resolved by its owners. The final lightweight proposal merge succeeded; full CLI validation remains with the parent.
