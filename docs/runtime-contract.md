# IdleQuest Lua contract

IdleQuest executes Lua using its Go quest bridge. It does not execute Perl.
`quests.lua_content` holds effective NPC/encounter code; `quest_lua_modules` holds
enabled shared modules. SQL snapshots are not a substitute for maintained source:
the ordinary importer can rebuild those rows later.

## Source precedence and identity

Read the exported `reference/server/cmd/import-quests/main.go` and
`reference/server/internal/quest/service.go` for exact behavior at this snapshot.
The importer loads upstream Lua and modules, then applies global corrections,
maintained overrides and exclusions. `-- name:` in a maintained Lua header can
override its filename's runtime NPC key. Preserve it.

The three maintained source categories are `converted-perl`, `modified-upstream`
and `idlequest-authored`. Original Perl/Lua remains untouched. Explicit enabled
state and the content-scope ledgers are separate from the existence of a script.
Numeric IDs, `#` names and plain names must not be flattened into one key.

## APIs and event execution

Use existing scripts and `reference/server/internal/quest/lua_bridge.go`,
`compat_globals.go`, and the adjacent responsibility-specific Go files as the
exact API reference. Typical entry points include `event_say(e)`,
`event_trade(e)`, `event_spawn(e)`, `event_death_complete(e)`, timers and signals.
The event's player, NPC, trade and encounter context depends on the event type;
do not assume a timer or NPC death always has a live player in `e.other`.

Calls capture effects for validated settlement. Inventory, spawns, timers, signals,
movement and rewards are not arbitrary immediate database mutations. Check the
source and existing regression tests for supported argument and lifetime rules.
Use shared item/turn-in helpers and preserve unconsumed items.

`reference/server/internal/quest/deferred_runtime_apis.json` is an explicit list
of known deferred calls. Absence from that list is **not** proof of complete API
support. Do not silently replace an unsupported mechanic with a no-op. Record the
needed capability or a documented approximation and test its observable outcome.

Quest-only faction checks deliberately return friendly values. Read
`faction_policy.go`; world faction and actual faction updates are separate.

## What this dataset does not emulate

Static database placement cannot establish rendered ground height, navigation,
visibility or scene availability. Some imported conditions and later-era fields
are reference data not consumed by the current runtime. A quest that compiles
still needs execution, transaction and lifecycle testing in IdleQuest. Rendering
claims require a rendered test, not a state snapshot or Go unit test.
