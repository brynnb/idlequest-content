# Returning reviewed changes to IdleQuest

Requirements: Node 22+, Go 1.23+, Git; MySQL 8 for database rehearsal. The Lua
checker uses the same gopher-lua version and normalization code as IdleQuest.
It compiles source without executing it. Syntax success does not establish API
support or quest correctness.

## Author and rehearse

Keep the exported baseline untouched. Copy a script to `changes/<review-id>/`,
edit it there, and create the proposal described in `changes/README.md`. Complete
before/after rows come from the baseline NDJSON, not guesses or the live server.
Use `-- enabled: false` in a leading Lua comment to intentionally disable a quest
or module; the row's enabled value must agree. Keep quest runtime keys unchanged.

Shared modules use `maintained/modules/<module-name>.lua`. These replace upstream
modules during normal import without editing the vendored original. Review ledger
sources may target `reference/server/internal/quest/content_exclusions.json` or
`reference/server/internal/contentscope/npc_exclusions.json`. Those map back to
the existing authoritative IdleQuest files, not a new parallel policy store.

```
npm ci
npm test
npm run validate
node tools/cli.mjs check-proposal . --proposal changes/REVIEW.json
node tools/cli.mjs preview . --proposal changes/REVIEW.json --env-file /outside/scratch.env --database idlequest_content_review
node tools/cli.mjs apply-scratch . --proposal changes/REVIEW.json --env-file /outside/scratch.env --database idlequest_content_review
```

Commit the reviewed proposal and its proposed files to a branch. Handoff requires
a clean checkout and the exact full 40-character commit ID. Nothing is fetched or
executed from the network by the handoff tool. Dependency setup uses the pinned
Node/Go package versions in this repository.

## Stage in the game repository

From the IdleQuest checkout, using its trusted tools:

```
node scripts/content/cli.mjs handoff ../idlequest-content --proposal changes/REVIEW.json --idlequest . --revision FULL_REVIEWED_COMMIT_SHA
```

This is preview-only. It validates the immutable baseline, proposal preimages,
the pinned Git files, Lua syntax and destination source hashes. To stage the
reviewed result, repeat with `--write true`. The tool allocates the next unused
migration sequence; it rejects existing migration files and stale source files.

The staged diff contains:

1. Exact maintained Lua/module or ledger source updates.
2. A normal `server/migrations/NNN_content_REVIEW.sql` file.
3. `data/content-releases/REVIEW.json`, pinning the content commit, manifest,
   proposal, generated SQL, source hashes, and complete row preimages for rollback.

Handoff does **not** touch a database, commit, push, build, restart, or deploy.
Review the diff and run the relevant IdleQuest mechanics tests before committing.
If interrupted during file staging, inspect the Git diff against the receipt;
do not deploy a partial diff. A leftover `.content-handoff.lock` indicates that
manual inspection is needed before retrying. Ordinary caught failures restore
files written by the operation if no concurrent edits have changed them.

## Apply through the existing deployment workflow

Rehearse the generated migration against the restored scratch database. Use
MySQL batch mode **without `--force`**, matching IdleQuest's deployment runner.
Schema/key guards and exact binary/numeric row preimages reject stale content.
Any failure aborts the batch client and rolls back its InnoDB transaction. Already
matching postimages are accepted for repeat application. Reference checks reject
new dangling IDs and deletion of referenced records.

The generated migration preserves omitted live fields. The rehearsal preview
rolls back row writes; MySQL allocation counters can still advance on an attempted
insert, which is one reason rehearsal is restricted to disposable databases.

Use IdleQuest's established backup/migration/build/restart/verification workflow
when deployment is separately authorized. Do not apply a volunteer's changes
directly to production. A later ordinary quest import uses the staged maintained
sources, including enabled headers, so it cannot silently undo those Lua edits.

Quest/module deletion is represented by explicit disabling while preserving
provenance. Existing historical dependencies may be broken in the baseline; the
static audit records them. New reference changes are checked, but dynamic Lua
IDs, composite path grids and rendered navigation still need targeted review.

After acceptance, create a fresh export for the next review baseline. Never edit
an existing baseline manifest to bless changed files or discard newer game fixes.
