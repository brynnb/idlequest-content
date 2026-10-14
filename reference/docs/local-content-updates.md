# Local content updates

Use `npm run content:update` from the game checkout to synchronize the local
database with the current migration and maintained Lua sources. It reads `.env`
and refuses non-loopback hosts or databases other than `eqgo`.

The command checks the existing migration ledger, makes a compressed local
database backup under `/var/tmp/idlequest-content-update-*`, applies pending
migrations with the same filename/checksum logic as production, invalidates the
generated `server/data/items.dat` cache, runs the full
quest importer, and verifies maintained Lua against the resulting database.
It stops at the first failure. It never guesses a baseline for an untracked DB.
Backups remain available after failures; it does not attempt automatic rollback
of migrations that may contain nontransactional DDL.

To produce a current volunteer snapshot, use:

```
npm run content:update -- --export /absolute/new-snapshot-directory
```

Export happens only after import and verification succeed. The destination must
not already exist. Use the normal content review process when replacing a prior
baseline; do not overwrite volunteer proposals or edits.

The low-level `scripts/content/export.mjs` remains a read-only snapshot tool and
does not synchronize content. Use the combined command for volunteer releases.

This does not deploy, push, restart services, or regenerate client assets. Stop
local play before updating; restart any running local server afterward so its
cached content reflects the database. Production continues to use the established
deployment workflow, which runs migrations and quest imports together.
