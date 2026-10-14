# Export and handoff verification

This is a local development content snapshot, not a production backup.

## Current synchronized snapshot — October 14, 2026

This refresh starts from public commit `3d2eb497`, preserving the existing
53-table allowlist, column projections, row filters, and published code paths.
Updated and new quest scripts stay within the existing quest content areas.
No additional database tables, schema columns, runtime source files, or
reference-code areas are included. The public README and review tools are
unchanged. Broader unpublished local content-repository history is not part of
this update.

The source checkout is based on `e92f5104` with local changes; individual
manifest hashes identify the exported file contents. All repository migrations
were already present in the local database with matching checksums, and the
quest importer verified 1,446 maintained scripts and one module. Export and
verification used read-only database snapshots; no migrations or quest imports
were applied for this refresh.

Current snapshot: 53 tables, 2,741,186 rows, 36,295 hashed files. Manifest SHA256:
`25d9be76c255b3d789927aa062e39afca2569bd8b863595e031311c7eab39535`.

- Full manifest, row-shape, primary-key and checksum validation passes.
- Every exported row matches a second read-only query of the local source,
  using the published table, column and filter policy.
- Seventeen review-tool tests pass; one optional SQL integration test is skipped.
- Scope checks found no new tables, columns, or reference-code paths.
- This snapshot was not reloaded into another scratch database, and no new
  browser or gameplay verification is claimed for this content refresh.

Existing schema files are retained because the projected schema is unchanged.
Existing reference files are updated within the published path boundary; they
remain excerpts, not a buildable copy of the closed-source game. New private
runtime files and an additional private export table are deliberately omitted.

## Previous synchronized snapshot — September 15, 2026

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
