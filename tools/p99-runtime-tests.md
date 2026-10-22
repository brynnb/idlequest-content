# Isolated P99 proposal behavior checks

Run from the content repository with Node 22+ and a real Go 1.23+ toolchain on
PATH:

    npm ci
    npm test
    npm run validate

To run only the added behavioral simulation:

    node --test tools/p99-content-behavior.test.mjs

The Node suite compiles `p99-lua-runner.go` inside the existing validator module,
so the dependency remains pinned to gopher-lua v1.1.1 by validator/go.mod and
validator/go.sum. It imports the repository's existing quest source normalizer.
Each scenario has a fresh VM and a 30-second execution deadline (a wall-clock safety bound, not a performance benchmark). The binary
is built into a disposable OS temporary directory and removed after the test.

The fixture loads the actual vendored items.lua but mocks character/NPC methods,
hand-in consumption, faction/reward capture, random choice (first option by default, with explicit option enumeration), and
signal dispatch. Unknown mocked APIs throw rather than silently succeeding.
Independent scenarios exercise dialogue branches, class/level cases, partial
and invalid offers, exact rewards and denominations, extra items/change,
repeat hand-ins, and ambient signal arguments. Scenario names print on success.

This is **isolated script behavior simulation**, not the IdleQuest bridge.
Item preservation means the mock leaves unconsumed IDs/currency and observes
ReturnHandinItems being called; it does not establish actual inventory return,
stacked item handling, atomic settlement, rollback, database persistence,
world spawn/death progression, signal delivery timing, or rendered UI behavior.
Random reward probabilities are not tested. Prerequisites are injected rather
than naturally acquired. Real engine mechanics and Docker UI tests remain
required in the private game repository before a playability claim.

The optional existing MySQL integration suite requires separate disposable DB
configuration and remains skipped when that configuration is absent. Passing
snapshot validation proves baseline integrity, not quest correctness.

The content suite also checks every currently proposed non-flavor Lua file has
at least one focused scenario. Flavor files are covered separately by
`p99-velious-flavor.test.mjs`. This source-coverage guard does not imply every
unchanged branch of every script is tested. The Warden recipe test checks the
proposed enabled/no-fail metadata and existing component/output rows only; it
never performs an actual Combine interaction. Zone flags and death-triggered
spawn calls are argument captures, not real access changes or world actors.

Known retained behavior is not concealed: Reebo consumes partial jumjum offers
without a reward in the existing script. Its partial cases assert no invented
reward rather than claiming those items return. Full acquisition chains remain
untested, and random-option enumeration establishes the offered outcomes, not
probabilities or sampling fairness.

Reviewer assertions are imported from the A–F, G–M, N–R, S and T–Z manifests.
They execute the current proposed file, checking supplied source hashes or
embedded source text to reject stale evidence. Reviewer-specific mock extensions
are scoped to that scenario. The one explicitly labelled baseline reproduction
is diagnostic only and does not satisfy proposed-source coverage. The synthetic
five-available-item case is not a real five-slot trade: the fixture exposes four
item slots while its availability map permits testing the script's reward cap.

`p99-recipe-structure.test.mjs` overlays proposed rows in memory and asserts all
22 currently reviewed recipes against `p99-recipe-expectations.json`. That
artifact includes exact component counts, container identities, output counts,
source links, cached evidence hashes and uncertainty notes. It distinguishes
baked muffins from vendor muffins and checks the returned baking tin. Retained
engine metadata is not silently treated as P99 proof. In particular, Tarton's
Wheel retains the known no-fail conflict pending supported failure semantics.
These checks do not simulate crafting, failure randomness, or consuming and
replacing containers in a live inventory.

Set `P99_TEST_RECEIPT=/tmp/p99-behavior-receipt.json` when running the main
behavior suite to save a machine-readable successful-execution receipt with
scenario names, current source paths and SHA-256 hashes. This receipt is emitted
only after every VM scenario passes; the separate proposal coverage guard must
also pass before claiming coverage of the current proposal set. A receipt does
not replace compiler validation or the full npm test exit status.

The VM directly evaluates candidate Lua regardless of a quest row's enabled
flag or whether its NPC can spawn. Passing a disabled candidate script does not
prove it is active or reachable. Compiler/header checks and activation decisions
remain separate. Read-only game-source evidence for Chalice's must_learn=48 is
linked from the expectation record: it establishes flag interpretation, not a
successful crafting interaction or UI availability.
