# Reivaj fang faction rewards

Reivaj currently exchanges fang25117 for sword25083 and1000 EXP without faction effects. This proposal adds the four faction directions shown by P99 and removes reward speech that the bundled ProjectEQ Perl calls made up.

## Identity and evidence

- Runtime key `kael/Reivaj_the_Battlerager`; quest row14529; NPC113248 (`data/npc_types/9.ndjson:160`). These IDs are distinct.
- Required item25117 is named `Bllizent's Fang` in `data/items/7.ndjson:918`; reward25083 is Vehement Sword of Reivaj in `data/items/d.ndjson:927`.
- P99 cache `reference/p99-wiki/raw-pages/blizzent-s-fang-quest-9877af8a5d.wiki`, fetched2026-07-17T23:08:17.353Z, SHA256 `1ef8a687cc424239b0bd6a2c559c0654e3fdd0832eb95040e1bda2b1ed7b66b4`, revision unavailable. The final hand-in lists Kromrif/Kromzek gains, Coldain/Claws of Veeshan losses, and explicitly says there is no dialogue.
- [Pinned EQMacEmu implementation](https://github.com/EQMacEmu/quests/blob/df860b6eb90bc11558111663fb61ae1b4493f56d/kael/Reivaj_the_Battlerager.lua), retrieved2026-10-21, supplies fallback amounts419 +25,448 +6,406 -12,430 -2. P99 establishes directions, not magnitudes. Existing1000 EXP and sword reward remain.
- `sources/projecteq/kael/Reivaj_the_Battlerager.pl` explicitly labels its reward speech `text made up`.

## Scope and adoption

Only the final hand-in changes. Quest faction bypass remains deliberate. The copied review ledger changes only this quest entry and marks the comparison partial. The large ledger copy is required by full-source proposal hashing.

NPC113248 and source NPC Blizzent118110 both have `exclude=1` in this export. This proposal does not enable world content or establish ordinary spawn eligibility or fang acquisition. It corrects the exported handler for adoption when the game owner chooses. No continuous-chain or playable-world claim.

The maintained Lua has a generated-source header referring to `server/internal/quest/velious_backlog_quests.json`. That generator input is absent from this content export. The game owner must incorporate this branch into that generator input before regeneration. The proposed source preserves the header and normal handoff target.

## Validation

`REIVAJ_SCRIPT=../effective/quests/kael/Reivaj_the_Battlerager.lua go -C validator test -run TestReivajFactionRewards -v` fails on missing Kromrif gain. The default test executes the proposed Lua with exported `effective/modules/items.lua` and passes. NPC/player methods are test doubles. It covers repeat independent offers, preserved sword/EXP, all four exact fallback effects, no hand-in speech, unrelated-item returns, and rejected offers.

Repository tests, dataset validation and exact proposal validation are recorded in the PR. These checks do not prove real inventory settlement, faction persistence, MySQL rehearsal, game UI, ordinary spawn/loot or full-chain behavior. Those were not run in this content-only environment.
