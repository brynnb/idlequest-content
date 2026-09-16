# Export and handoff verification — September 15, 2026

This is a local development content snapshot, not a production backup.

## Current synchronized snapshot

The game checkout's combined local update command checked every migration
filename/checksum, backed up the database, applied 11 unrecorded migrations,
imported quest Lua, and verified all 1,270 maintained scripts against the DB.
The ledger now contains all 155 migration files through sequence 152; migration
files themselves are not included in this repository.

Current snapshot: 53 tables, 2,737,222 rows, 36,050 hashed files. Manifest SHA256:
`01b7a268f76b1fd73ad90502cc78bf932556881b004fe615c8a6d8068a61b4c1`.

City of Mist handlers 90000/90010/90199 are enabled, and the lesser-spirit
directions match the production script checked earlier. The local froglok cleanup
is retained. Offline wiki page bytes are unchanged; scrape-progress paths have
been made relative for public sharing. Seventeen standalone tests and
full snapshot validation pass. Local orchestration/deployment checks pass; a
real-DB temporary-table test verifies source drift and missing-row rejection.
This refreshed snapshot was not reloaded into a second scratch DB; the initial
loader and migration round-trip evidence is recorded below.

## Initial tooling verification (before synchronization)

- 53 allowlisted tables, 2,737,219 rows and 36,045 hashed baseline files.
- Manifest SHA256: `ed72befc452a59ad7dfd42ad9622419d1812bc6f336b688caefe79d2caa58e4f`.
- All 826 data/schema files match the snapshot loaded into isolated MySQL 8.4
  and verified by reading every projected row back. All 1,177 schema columns
  match MySQL types and nullability.
- `npm test`: 15 passing focused tests; database integration is opt-in.
- The separate real-MySQL suite passed seven results: preview rollback,
  application/reapplication, generated deployment SQL, stale-row rollback,
  reference failure rollback, schema drift, and malformed proposal rejection.
- The pinned handoff test stages a real Lua source and ledger in a temporary
  game checkout, compiles Lua, and verifies stale/dirty/revision refusal.
- IdleQuest's quest, override, shared Lua-source and importer Go packages pass.
  Opt-in tests loaded actual restored NPC scripts and shared modules, exercised
  Ton's two independent mail hand-ins and unrelated-item retention, and checked
  ordinary spawns, advisor-triggered Black Dire, and NPC/loot/item links.
- Repeated importer tests preserve maintained module and quest enabled state.

`npm run validate` verifies the full baseline. See `docs/handoff.md` for the
proposal and return workflow. No browser/rendered result is claimed here.

The source index retains 11 source/database Lua disagreements. The static-link
audit records pre-existing missing references without pretending they are all
in-era defects. Later-era rows remain reference data, not permission to enable
them. This work does not complete the volunteer's P99 content audit.

No production changes, remote repository, push, or deployment were performed.
