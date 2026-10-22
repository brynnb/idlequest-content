# Final bounded uncertainty review

Exactly 46 assigned existing Lua sources were read in full, including all say,
trade, timer, combat and slay handlers. One source, Sir Ariam, is referenced to
its existing owner rather than duplicated. The initial overlay snapshot and
repeated proposal overlap check prevent competing edits.

The proposal contains 17 complete-body archival disables and one narrow guard
of the positively PoP Aid Garuuk branch in mixed Grobb Bregna. Classic candidate
belt behavior, NPC rows, merchant inventories, engine adaptations and all
historical disabled callbacks remain unchanged. Disabled Lua is force-loaded
only in isolated verification, not admitted to game dispatch.

One exact service uncertainty is resolved positively: the official P99 patch
confirms Palious Jarten's ten-gold Cure Disease. Other unresolved sources retain
individual behavior and uncertainty; absence of cached names is not an
exclusion. The assigned set contains 13 Exterminator keys, not 16; all retain
their differing currencies, factions, XP and callbacks. The contemporary 2003
family evidence is recorded without extrapolating exact actor admission.

Run `python3 changes/p99-final-uncertainty/build.py`, then
`python3 changes/p99-final-uncertainty/build-tests.py` and
`GOPATH=/tmp/p99-go-path GOCACHE=/tmp/p99-go-cache node changes/p99-final-uncertainty/check.mjs`.
The actual CLI check is separate:
`PATH=/tmp/p99-go-toolchain/go/bin:$PATH GOPATH=/tmp/p99-go-path GOCACHE=/tmp/p99-go-cache node tools/cli.mjs check-proposal . --proposal changes/p99-final-uncertainty.json`.

No live game transaction, natural acquisition, multiplayer, or rendered UI
verification is claimed. Source-only disable does not remove an NPC spawn.

Twelve immutable upstream sources are proposed as new maintained Lua overrides
with null preimage hashes. Six existing maintained sources retain their exact
preimage hashes. The review separately binds every original baseline source;
no immutable source file is overwritten.
