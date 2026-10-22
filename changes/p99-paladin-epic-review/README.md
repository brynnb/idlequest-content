# Paladin Epic Quest: full source-facet review, path still open

This review replaces the page's screen-only state, not its partial/playability status. The entire cached epic page, nine direct current Lua bodies, ten direct NPC pages, exact item identities, actor policy maps, spawn candidates and complete loot-pool links were read. Four existing source-aware precursor reviews are reused only at their documented scope after checking their current source/proposal hashes.

## Bounded proposals

- `changes/p99-paladin-jark-some.json`: accept the main page's standalone `some` prompt while retaining `something`, dinner, spawn and trade behavior.
- `changes/p99-paladin-reklon-dialogue.json`: restore `There` in the truncated fallen-from-grace response. All hand-ins and rewards are unchanged.

No immutable baseline, existing proposal, faction policy, minimum-level policy or engine adaptation was modified. No commit, push, PR, migration application or deployment was performed.

## Evidence and scope

- `manual-facet-review.json`: one-record NZ-style source-facet artifact with every open limit.
- `ledger-records.json`: title-keyed partial ledger, preserving existing historical UI verification.
- `evidence.json`, `item-identities.json`, `acquisition-data.json`: exact cached evidence, 23 item records and 19 actor identities with policy checks, full linked loot pools and spawn competitors. Raw `exclude=1` is not a ban.
- `reused-review-checks.json`: 31 baseline source hashes and 15 proposal hashes checked for Fiery Avenger, Sword of Nobility/Ghoulbane, SoulFire and Pure Crystal. All match; original review scope and unresolved notes remain visible.
- `supporting-recipes.json`, `recipe-expectations.json`, `recipe-tests.json`: three current precursor structures pass explicit static checks using the standard expectations schema and existing proposal overlays. The direct epic cleansing exchanges are NPC hand-ins, not recipes.
- `runtime-assertions.json`, `test-review.mjs`, `isolated-tests.json`, `isolated-tests.log`: 45 current-source scenarios using the shared strict fixture, real vendored item helper and pinned Go normalizer/VM. Baseline verification/reproduction cases do not count as proposed-file coverage.

Run from repository root:

    GOCACHE=/tmp/p99-go-cache GOPATH=/tmp/p99-go-path node changes/p99-paladin-epic-review/test-review.mjs

Proposal checks use the normal `tools/cli.mjs check-proposal` command with `/tmp/p99-go-toolchain/go/bin` on PATH. Their durable receipts are alongside this README.

## Explicit limits

This is not a fresh game-bridge, atomic inventory/rollback, world combat/death/loot, rendered UI or continuously acquired epic test. The inherited historical UI receipt is not promoted to a current pass.

The existing Plane of Hate test deliberately protects direct scorn-banshee breastplate availability and a static Thought Destroyer; these stay intact instead of fabricating corpse-spawn odds. Keeper/Kirak respawn differences, Keeper/Nella coordinates, ambient emotes, cross-player multiquest, predecessor acquisition, optional Ghoulbane crafting, reward charge control and all recipe/live-engine limits remain open. Full details are in the facet record.
