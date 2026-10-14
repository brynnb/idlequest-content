# P99 quest audit and update workflow

## Current interaction-test workflow

September7 user refinement: epic death-trigger tests default to the test-only
**Test Quest Strike** button. It is an instant, fixed powerful hit through the
existing Harm Touch damage entry, not an HP assignment or direct death/loot
command. The fixture first enters normal server-owned combat, clicks the real
button, and waits for the exact server corpse and scripted consequences.
No spell preparation, cast wait, HP/max-HP mutation or camping is needed.
This supersedes the older mandatory10HP/class-specific finisher guidance for
quest mechanics. Explicit ordinary spell/melee regressions may still opt in;
quest-strike passes do not prove normal casting, pathing or encounter balance.

Use the shared real-UI fixture and step checklist in
[Real-UI quest verification](quest-ui-verification-status.md). The user clarified
that ordinary spawn and loot tables can be trusted: seed prerequisites, then
verify actual dialogue choices, Give/Combine, consumption, rewards and scripted
NPC consequences. Do not camp rare drops or require natural acquisition of an
entire epic to validate these interactions. Debug quest say/turnin commands are
not substitutes for the UI under test. The old acquisition log is historical.

The compact shared regression set and current boundary evidence are documented in
[Quest mechanics regression set](quest-mechanics-regression.md).

## Authority and provenance

For IdleQuest Classic/Kunark/Velious quest content, Project 1999 is the gameplay
authority when its documentation is clear, except for deliberate IdleQuest
convenience rules below. ProjectEQ is an implementation source and
compatibility reference, not the final content authority. The current audit
scope is `server/internal/contentscope/p99_zones.json`: Classic through Velious,
including Warrens and Stonebrunt. Inclusion means inspect the content, not enable
the zone or every imported script. Old era-only exclusions have been reopened
with provenance; actual later-era and event exclusions still require respect.

Current implementation work is tracked in
[P99 quest parity plan](p99-quest-parity-plan.md). Run
`node scripts/quests/quest-status.mjs` against the local database for a derived
summary, or add `--json /var/tmp/quest-status.json` for individual records.

### Deliberate quest faction bypass

The user confirmed on September 5, 2026 that quest faction must not block
progress. AutoLevel routinely damages factions and faction planning is not a
desired prerequisite. `faction_policy.go` owns this exception for Lua quest
readers: `GetFaction` returns Ally (`1`), and `GetCharacterFactionLevel` /
`GetModCharacterFactionLevel` return `combat.FactionMaxValue` (`2000`).
Do not fix these back to P99 requirements or seed friendly factions to hide a
runtime regression. Keep actual faction changes and persistence intact; world
con, aggression and merchants do not use this quest-only policy. This does not
bypass required items, class/race/level, or explicit quest-state prerequisites.
Some historical quests used faction as a progress counter; the faction-only
gate is intentionally waived, not replaced with a new hidden prerequisite.

### Deliberate epic level exception

As of October 12, 2026, epic 1.0 quest steps have **no minimum character level**.
Remove their level predicates in the maintained quest sources, including
speech, hand-ins and encounter triggers. Preserve existing class, item,
quantity and quest-state prerequisites. Do not fabricate a higher player level
in the shared Lua runtime or remove level gates from unrelated quests.
See [Epic level requirements](epic-level-requirements.md) for the audited scope
and verification. This supersedes older epic-specific notes retaining levels.

Use this order when sources disagree:

1. Cached P99 quest and NPC evidence for era, progression, dialogue, required
   items, rewards, faction, encounters, and drop sources.
2. Other classic-era evidence when P99 is incomplete or internally
   inconsistent. Record the source and decision.
3. ProjectEQ Perl/Lua for implementation details that P99 does not document.
4. A conservative IdleQuest approximation when the real mechanic is not
   supported. The approximation must be documented and tested.

Never infer that a Lua file is wrong solely because it differs from ProjectEQ.
The repository was built in two phases: bulk ProjectEQ Perl-to-Lua conversion,
followed by a large P99-authority correction pass. Many omissions and changes
are deliberate removals of later-era or non-P99 behavior.

Quest source directories describe provenance:

- `server/internal/quest/upstream/projecteq/`: unmodified vendored ProjectEQ
  Lua.
- `server/internal/quest/upstream/eqmacemu/`: byte-preserved, commit-pinned
  TAKP implementation references. These are not imported as runtime scripts;
  reviewed adaptations belong in the maintained overrides. Each added source
  has its upstream URL/revision and SHA-256 in the relevant content manifest.
- `server/internal/quest/overrides/lua/converted-perl/`: locally converted
  ProjectEQ Perl, historically including LLM-assisted conversions.
- `server/internal/quest/overrides/lua/modified-upstream/`: upstream behavior
  deliberately changed for IdleQuest/P99.
- `server/internal/quest/overrides/lua/idlequest-authored/`: new local
  implementations where a usable upstream implementation was absent.

## Preserved P99 corpus

The local cache is `data/p99wiki-project1999-api-cache/`. It is intentionally
ignored by Git, so it must be copied before deleting a worktree or workspace.

The preserved July 17, 2026 quest corpus contains:

- `quest-related-pages.json`: the audit universe and classification.
- `raw-pages-state.json`: fetch completion and provenance.
- `raw-pages/`: 1,135 raw MediaWiki pages and 1,135 matching metadata files.
- 918 high-confidence pages found through the P99 quest category tree.
- 217 title-review candidates used as a safety net.

The same cache root also contains the later NPC-page corpus. Do not replace the
whole directory when restoring one corpus; merge its subdirectories and
manifests.

Before an audit, verify the preserved corpus:

```sh
test -f data/p99wiki-project1999-api-cache/quest-related-pages.json
test -f data/p99wiki-project1999-api-cache/raw-pages-state.json
find data/p99wiki-project1999-api-cache/raw-pages -maxdepth 1 -name '*.wiki' | wc -l
find data/p99wiki-project1999-api-cache/raw-pages -maxdepth 1 -name '*.json' | wc -l
```

Both final counts should currently be `1135`. Do not silently replace this
historical snapshot with newly fetched pages: a later wiki revision may explain
content differences. Keep the old snapshot or record hashes and fetch dates
before refreshing it.

The raw-page manifest retains absolute paths from its original worktree for
provenance. Title triage resolves each declared `raw-pages/<filename>` member
under the current cache root and verifies the preserved metadata's title, byte
count and SHA-256. Do not rewrite the historical manifest or restore a removed
worktree merely to satisfy those paths. Missing or changed evidence is an error,
not an empty page. Reader regression:
`node --test scripts/quests/triage-p99-title-review-candidates.test.mjs`.

Historical generated reports from the original conversion/audit effort are
preserved under
`testing/reports/historical/2026-07-quest-audit/`. They are useful baselines,
not current pass/fail authority.

## Durable review record

IdleQuest keeps P99 review state in
`server/internal/quest/content_exclusions.json` under `p99_audit`. This tracked
ledger—not comments in an individual Lua file—is the durable record of what was
reviewed, changed, simplified, excluded, or left uncertain.

Each reviewed page should record:

- P99 title, URL, and cached raw-page path;
- scope and review status;
- local quest keys and effective Lua files;
- whether dialogue, gates, turn-ins, rewards, faction, spawns, and supporting
  content agree;
- intentional substitutions or unsupported mechanics;
- unresolved evidence conflicts;
- focused test or fixture evidence;
- review date.

`reviewed` does not mean perfectly emulated. Read `match_status` and `notes`.
Statuses such as `needs_review`, `ambiguous`, `partial`, or a documented
runtime simplification remain actionable.
It also does not mean a continuous chain or rendered playthrough passed. Record
the exact test and what it observes, not a general claim of E2E coverage.

`scope_reassessment` preserves a previous scope decision and its reason when
the supported era changes. It does not change the separate runtime `quests`
exclusion map. `verification.ui` and `verification.connected_chain` hold
independent evidence, including command/spec, scope, date and durable receipt
when available. `historical_pass` specifically means a recorded older result,
not a fresh successful run. Missing evidence is `not_recorded`, never an implied
pass or proof that no test exists. Lua availability and references to deferred
APIs are derived from current database scripts by the status tool; do not
duplicate those mutable facts into each source-review entry.

The source-only runtime matrix now defaults to the P99 audit scope. Its explicit
all-imported-content opt-in is `IDLEQUEST_QUEST_TEST_P99_ONLY=false`; it is still
not a world/quest-playability test. The old Classic/Kunark variable and scope file
have been retired.

Use the tracked notes for decisions too large or uncertain for one ledger row:
`docs/quest-audit-review-notes.md`.

### Import exclusions and reviewed replacements

`content_exclusions.json.quests` excludes an upstream quest key. A maintained
replacement may remain enabled only when that same entry explicitly identifies
`reviewed_override`, for example
`"reviewed_override": "modified-upstream/burningwood/a_sarnak_imitator.lua"`.
This is an affirmative content decision, not permission for arbitrary future
branches. A whole-script exclusion must also use `-- enabled: false` if a
maintained reference script exists. Preserve that header in proposals.

The importer embeds the existing ledger and validates the whole maintained
corpus before writing. A missing/disabled/wrong-origin approved replacement,
duplicate key, or enabled source conflicting with a whole-script exclusion is
an error. A working-directory mistake can no longer silently omit exclusions.
`--verify` checks both source equality and excluded enabled database rows,
including upstream-only rows. `quest-status.mjs` reports those conflicts too.
The separate NPC content policy still applies; this does not enable an NPC,
zone, loot source, or a quest that lacks a reviewed implementation.

## Upstream zone versions

The full importer reads both `<zone>/*.lua` and `<zone>/v0/*.lua` into the
actual `<zone>` key. `v0` denotes the original zone population, never a zone
called `v0`. Later `v1` sources remain excluded from this import. A duplicate
root/v0 NPC key fails discovery before any import; resolve the provenance rather
than silently choosing one. Reviewed bundled overrides still take precedence.
Legacy rows whose zone is `v<number>` are disabled, and `--verify` rejects them
if an older import re-enables them. This repairs 16 classic Lua sources in
Droga, City of Mist, Lavastorm and Splitpaw without enabling later zone revamps.

## Applying one reviewed override locally

The full importer rewrites upstream quests, modules and global fixups. For an
existing enabled quest whose bundled override has been reviewed, use its exact
runtime `zone/name` key instead. With the local development DB environment
loaded, run from the repository root:

```sh
go -C server run ./cmd/import-quests --override qcat/Teydar
go -C server run ./cmd/import-quests --override qcat/Teydar --apply
```

The first command is a dry run. Both report the source origin and before/after
SHA256 hashes. The apply command updates only Lua and the dialogue-presence
flag; it does not create quests, re-enable disabled content, update modules or
run global fixups. Unknown/ambiguous keys and case-mismatched database names are
errors. Selection uses the same embedded overrides and sanitization as the full
importer, including explicit `-- name:` metadata. This does not replace the full
deployment/content migration workflow or authorize production writes.

Existing dialogue bodies are read from the database on requests. Changes that
add/remove runtime event handlers can additionally require a server restart
because handler-presence discovery is cached. Verify the actual browser path;
an import receipt alone is not evidence of gameplay working.

## Page selection

`highConfidencePages` in `quest-related-pages.json` are namespace-0 pages found
through P99 quest categories. They are the primary authoritative batch.

`titleReviewCandidates` are heuristic hits outside those categories. They
include redirects, item pages, notes, guides, and indexes, so triage them rather
than implementing them automatically:

```sh
npm run quests:triage-p99-title-candidates -- --details
```

The important field is `remainingManualReview`. If it is nonzero, inspect every
listed page and either implement an in-scope quest, record an exclusion, or
document the ambiguity. Do not treat title-only candidates as automatically
valid quest pages.

## Per-quest review procedure

1. Read the cached P99 quest page and the relevant cached NPC pages. Note the
   exact revision snapshot being used.
2. Identify every involved NPC, zone, dialogue phrase, faction/level/class
   gate, item and quantity, reward, recipe, ground spawn, loot source, spawned
   encounter, timer, signal, and death step.
3. Resolve the effective local Lua through the quest import/override layout.
   Do not compare only against a same-named upstream file that is overridden.
4. Compare the local database too. A correct script is not playable when its
   NPC, item, loot, recipe, ground spawn, or zone mapping is missing or belongs
   to a later era.
5. Classify every difference as a P99 correction, intentional supported
   approximation, documented ambiguity, out-of-scope content, or actual defect.
6. Update Lua/data only where the evidence is clear. Do not invent exact cash,
   experience, faction values, reward odds, or dialogue that P99 does not
   establish; retain a defensible classic implementation and document it.
7. Update the P99 ledger and review notes in the same change.
8. Add focused assertions for the behavior that changed, then run the relevant
   mechanics and real-client content tests.

Large multi-zone chains and epics require an end-to-end chain audit. A passing
individual turn-in is not evidence that drops, spawned combat, recipes, and
subsequent steps are correct.

### Check ordinary NPC spawn dependencies

For NPCs that should be found in the world (not created by a quest event), use
the read-only checker against the local database with the normal environment:

```sh
set -a
. ./.env
set +a
go -C server run ./cmd/audit-quest-spawn-dependencies -zone hole -npc 39069,39082
```

It uses `GetZoneSpawnPool` and the same `BuildSpawnSelection` as the live
population service, including its actual content-flag filters and positive
weight rules. It prints exact placement IDs, respawn times and probabilities.
Exit 1 means at least one declared static dependency has no proven selectable
placement. A database row with zero weight among positive competitors does
not count as obtainable. Multi-entry all-zero fallback order is uncertain and
must not be reported as a reliable spawn. A missing eligible entry can also
mean filters or intentionally quest-triggered content; inspect the cause.

This is a static dependency check, not live presence, P99 spawn-rate validation,
full expansion/timeline validation, or a test of quest-triggered actors. Do not
put Kyrenna or another intentionally spawned actor in the static requirements
just to turn its expected absence into a content failure. Continue to verify
those actors through the actual event -> combat -> death -> loot path.

## Runtime safety requirements

These are defects regardless of what ProjectEQ or P99 says:

- unmatched items must be returned unless consumption is explicitly intended;
- item ID `0`, missing rewards, missing required items, and invalid NPC/spell
  IDs must fail validation rather than reach players;
- turn-ins and rewards must be atomic and rollback safely on failure;
- dialogue buttons must send a phrase that actually reaches the intended Lua
  branch—bracket text is not necessarily a valid standalone response;
- personal quest spawns, hate/engagement, timers, zoning persistence, death
  events, and follow-up spawns must be tested when the quest depends on them;
- a generic script-execution test is not enough to prove the correct reward,
  amount, target, faction direction, or next quest state.

## Validation

Run the static content gates after each focused batch:

```sh
npm run quests:content-audit
npm run quests:triage-p99-title-candidates -- --details
```

Run focused Go/unit tests for the modified runtime and quest behavior. Content
authority sweeps are opt-in and should only be run for an explicit content
audit.

All Playwright/e2e runs must use the Docker wrappers. Named epic scripts already
set the required content-audit flags, for example:

```sh
npm run test:e2e:ranger-epic
npm run test:e2e:enchanter-epic
```

For a new fixture, use `npm run test:e2e:docker -- ...`; never invoke the local
Playwright binary directly. Start `npm run dev:test` first when the real game
stack is required.

## Completion standard

A quest is only "P99 aligned" when the evidence covers its complete playable
path: discovery/dialogue, eligibility gates, required item sources, every
turn-in, rewards and faction, recipes, spawned encounters and deaths, and the
next state. If any of those are unverified, say exactly what is covered and
leave the ledger open rather than claiming full alignment.

### Test evidence levels

For quest-mechanics encounter checks, the user explicitly permits reducing
the actual quest-spawned enemy to 10 HP before normal combat. Keep its exact
identity, real death processing and unmodified loot/reward path. Label this
as reduced-HP quest mechanics, not encounter balance or a faithful full-strength
fight. Do not spend quest-audit time on party gearing or raid mechanics to
make those checks pass. Debug defeat and fabricated intermediate loot remain
separate, weaker evidence.

- **Static review:** source/ID/API checks; no claim of execution.
- **Isolated hand-in:** real client/server transaction with seeded requirements;
  subsequent steps may be seeded too. Existing epic fixtures default to
  `isolated-steps`, not full epic completion.
- **Continuous chain:** set `verification: "continuous-chain"` and declare
  `startingItems` / `startingCurrency` once. Later missing items fail without
  repair. Every accepted hand-in checks consumption and resulting inventory /
  money. Debug spawn/defeat/forced-loot shortcuts are rejected. Initial debug
  setup and command-driven zoning are still allowed and must be disclosed.
- **Rendered playthrough:** actual UI, movement, encounters, drops, loot and
  chain continuity observed through the GPU Docker runner. A paused canvas or
  debug defeat is not this level of evidence.

Start `npm run dev:test`, then `npm run test:e2e:quest-chain-smoke` for the small
Seal of Kastane -> Note to Marl -> Marl delivery regression. It is deliberately
not advertised as the complete SK epic.

The shared deferred API registry records known no-op world effects. Reached
calls appear in `QuestCapture.DeferredAPIs`; `LuaBridge.RequireImplementedEffects`
rejects them in strict behavior tests. Production retains compatibility until
each effect is implemented. The turn-in exporter excludes reached deferred
effects from runnable coverage, and the selection generator also excludes
branches statically referencing them. Other APIs are not automatically proven
correct merely because they are absent from this initial registry.

See `docs/quest-system-roadmap.md` for the next implementation sequence and
independently scoped content tasks.
