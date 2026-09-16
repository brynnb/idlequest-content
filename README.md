# IdleQuest Content

This repo is a public workspace for the NPCs, spawns, loot, and quests for the idlequest.net game, which is a Classic-to-Velious recreation of classic EverQuest that runs in your browser.

IdleQuest began with a database snapshot from the TAKP project and, over the last couple of years, has been updated to try to match Project 1999 content as closely as reasonably possible. Additionally, it aims to convert all Perl scripts to Lua. TAKP had a mixture of both, but it's messy to maintain both formats, so there has been an ongoing conversion process.

Much of the work here is disorganized, half-baked, scattered, and incomplete. There have been multiple incomplete rounds of converting and updating content to match P99 wiki pages. Ideally, this project should have a clear record of what's been done, what's partially done, and what remains. As of this writing, it does not.

This snapshot also includes later-era reference records from the original TAKP database. These have not been explicitly cleaned up, but they probably should be. A lot of this stuff has remained so far because, as development progressed, it wasn't clear what the exact cutoffs were going to be for items, tradeskill recipes, etc.

Finally, included is a scrape of all NPC and quest pages from the P99 wiki, with the intention of preventing contributors from having to re-scrape the same content and place unnecessary strain on their server. If anyone at P99 is reading this and wants me to remove it, please let me know. It won't be a problem.

This entire repo, including its documentation and structure, aside from the README content above, was assembled by AI, and there may be some bad or dumb decisions in it. I wanted to get this repo out for anyone who wanted to contribute, and I haven't had time for a more thorough human review. So take it all with a grain of salt. Feedback is encouraged and appreciated!


## Start here

1. Read `CONTRIBUTING.md`, `docs/runtime-contract.md`, and `docs/handoff.md`.
2. Run `npm ci`, then `npm test` and `npm run validate`.
3. Look up the NPC's exact ID and quest key. Open
   `reference/effective-quests-index.json` to find the Lua actually stored in the
   database and its relationship to maintained/upstream source.
4. Review P99 evidence and propose a bounded correction. Do not reconvert Perl
   without reading the existing Lua and its review notes.

## Layout

| Directory | Meaning |
| --- | --- |
| `sources/projecteq/` | Original vendored Perl, Lua, modules and supporting files; do not edit |
| `maintained/lua/` | Snapshot of converted Perl, modified upstream and locally authored Lua |
| `maintained/modules/` | Reviewed shared-module replacements, applied after upstream modules |
| `effective/` | Exact database Lua at export time, including disabled rows |
| `data/<table>/<shard>.ndjson` | Stable-ID, lossless authored/reference table rows |
| `schema/` | MySQL table definitions; omitted live fields receive defaults on scratch load |
| `reference/` | Source mapping, evidence links/hashes, policies and quest-related import/runtime/test source |
| `reference/p99-wiki/` | Offline P99 wiki text, page metadata, indexes and scrape progress |
| `changes/` | Review proposals and proposed files; baseline stays immutable |
| `manifest.json` | Export hashes, row counts, filtering, source commit and exact source-file fingerprints |
| `tools/` | Validation, scratch loading and review tooling |

All content comes from a **local development snapshot**, not a claim about the
currently deployed production database. Dirty working-tree content is captured
by file hashes; the source commit alone is insufficient to reproduce it.

The core links are:

```
zone.short_name -> spawn2.zone
spawn2.spawngroupID -> spawngroup.id -> spawnentry.spawngroupID
spawnentry.npcID -> npc_types.id
npc_types.loottable_id -> loottable.id -> loottable_entries.loottable_id
loottable_entries.lootdrop_id -> lootdrop.id -> lootdrop_entries.lootdrop_id
lootdrop_entries.item_id -> items.id
quests.(zone,name) -> exact name/ID resolution in the IdleQuest quest service
```

NPCs created by scripts may have **no static spawn**. Retain them. Names are not
unique identifiers: `#` variants, numeric script names, sane/insane and hand-in/
combat replacements can intentionally be different NPC records.

## Scratch database

Use MySQL 8, with a **local disposable server**, and put credentials in a file
outside this repository:

```
DB_HOST=127.0.0.1
DB_PORT=13316
DB_USER=your_local_scratch_user
DB_PASS=your_local_password
```

```
node tools/cli.mjs load . --env-file /path/outside/repo/scratch.env --database idlequest_content_review
node tools/cli.mjs verify-db . --env-file /path/outside/repo/scratch.env --database idlequest_content_review
```

The loader creates a **new** database and refuses existing names. It never resets
or drops a database. A failed partial load is left for diagnosis. Use another
new name after correcting the failure. This schema is for content review, not a
complete running IdleQuest server with accounts and world state.

The database snapshot already contains the current content. No historical
IdleQuest migrations are included or required to load it.

Source-to-database differences and unresolved dependency issues must remain
visible. A validator passing means the export is intact; it does not mean every
quest is correct, in era, or playable.

No game models/textures, credentials, accounts, characters, chat, inventories,
live timers or saved quest progress are included.

Use the offline wiki first: search `reference/p99-evidence-index.json` by title,
then open its `cachePath`. The `.wiki` files contain MediaWiki source text,
not rendered HTML or images. URLs, retrieval dates and hashes accompany pages.
This is the existing partial scrape, not a complete or continuously updated wiki.
Only fetch a page when it is missing or a specific review needs newer evidence.
Scrape progress paths are relative to `reference/p99-wiki/`; the evidence
index's `cachePath` is relative to this repository root.

The review tools need Node 22+ and Go 1.23+. Proposed Lua is compiled using the
same gopher-lua version and shared source preparation as the game. The final
source/migration handoff requires an exact reviewed Git revision and refuses a
dirty content checkout. See `docs/handoff.md` for the complete return workflow.
