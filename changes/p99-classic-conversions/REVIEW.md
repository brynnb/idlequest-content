# Classic/Kunark missing-Lua review

Review date: 2026-10-22. Baseline unchanged. This directory contains proposals,
not imported or deployed game content. No commit or deployment performed.

## Results

181 unlinked missing-Lua Perl keys were inspected in the exact recovered zone
scope, excluding Velious and the separately reviewed Kithicor, Unrest and Cazic
Thule zones. `triage.json` records every exact key, source hash/path, decision,
and concrete source markers. No numeric ID is used to infer era. Three additional
wiki-linked keys were assigned during review (two hashed tainted actors and the
Minotaur Lord); they are in the proposal, not counted in the 181-key denominator.

Six exact-key Lua proposals:

- gfaydark/Sindl_Talonstrike, NPC 54107: hail and both Soldiers of Tunare /
  harvesters choices. P 99 describes this dialogue; wording retained from PEQ.
  Standalone bracket choices now reach each branch. Later tome training omitted.
- qcat/Zaen_Kalystir, NPC 45068: original guild hail only. P 99 confirms classic
  NPC identity; exact greeting is the documented ProjectEQ fallback. Later tome
  training omitted. Both guildmasters return all offered items/currency.
- emeraldjungle/#tainted_gorilla, NPC 94125: death spawns corrupted_gorilla 94140.
- lakerathe/#tainted_aquagoblin, NPC 51151: death unique-spawns corrupted_aquagoblin 51149.
- lakeofillomen/#tainted_barracuda, NPC 85217: death spawns corrupted_barracuda 85224.
  All three retain death actor coordinates/heading and exact source API. Existing
  plain-name versions are not overwritten. Runtime service.go does not strip #.
- steamfont/Minotaur_Lord, NPC 56161: aggro quote matches P 99, death quote retained
  from PEQ. This does not implement or claim verification of Minotaur Hero's
  separate spawn cycle; no unsupported probability is invented.

`proposal.json` contains exact full baseline rows and new maintained sources.
`ledger-additions.json` supplies partial-review records for consolidation into
one authoritative ledger proposal, avoiding collisions with other workers.
P 99 source metadata contains URL, retrieval date, checksum and revision absence.

## Important non-conversions

Four legacy Neriak hyphen keys resolve to actual backtick NPCs and existing
maintained `-- name:` overrides (Camia, Gath, Jayna, Eolorn). Their original
starting-note behavior is already present; Eolorn also includes The Rogue Take.
Do not duplicate aliases or restore later Tradeskill Basics book branches.

Most remaining scripts describe post-era content: Wayfarers/LDoN, Shadowrest,
LoY pirate/cultural/freed-slave chains, novice armor, later epics, Illusion Guktan,
Veksar, revamped VP, task-system quests and GM/holiday events. Original references
remain untouched. Category decisions are static source triage, not blanket proof
of every line's historical absence. Bidils, Verrell scale exchange and Welnik's
picks remain expressly unresolved when preserved P 99 evidence is insufficient.

Two Bilge helper scripts include Fabled actors and explicitly warn their NPC IDs
are not PEQ IDs. Do not mechanically port their 85/10/5 distributions.
Charasis/ Neriak player door scripts mix plausible original mechanics with later
branches and need actual runtime door/key integration. Vox/Nagafen player-target
banishment requires target-event/combat semantics validation. Anonymous North Ro
proximity teleport is not established as a P 99 boat replacement. Placeholder
GM speech/tome-only scripts are not promoted to quests without evidence.

## Verification boundary

`node --test changes/p 99-classic-conversions/behavior.test.mjs` passed 19 scenarios
on 2026-10-22 using the pinned gopher-lua VM and real item module, with explicit
strict mocks. Covers each dialogue choice, unknown speech, full item/currency
preservation/repeat offers, exact spawn API/ID/coordinates without player context,
and Minotaur aggro/death speech. Does not prove real rollback, settlement, world
lifecycle, timers, targeting, spawn selectability, or rendered UI.

`dependency-evidence.json` records source/target NPC identities, exported spawn
entries/weights, and zero matching NPC/quest exclusions. Exported weight rows are
not the live `BuildSpawnSelection` check. Whole-chain and Docker UI work must be
performed in the private game repository before claiming playability.

Static proposal validation passed: 6 rows, 6 sources, zero failures.
The triage regression also passed both exact-coverage/source-hash and six-key
proposal preservation tests.
