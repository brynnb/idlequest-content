# Restore Gretta's muffin quest

Gretta Mottle, NPC 60000 in `kaladima`, advertises a muffin task but gives
truncated instructions and no crate. She has no trade handler. The existing
Full Muffin Crate recipe is disabled. These gaps block the P99-documented task.

This proposal updates quest 19379, runtime key `kaladima/Gretta_Mottle`, its
maintained converted-Perl override, recipe 12811 and the existing audit note.

- Accept the documented `I will help to bake` and `I will help bake muffins`
  phrases, plus the bracketed links and existing `what` phrases.
- Give Muffin Crate 17881 and explain filling and sealing it.
- Enable existing recipe 12811. Its entries require ten Muffins 13014 in
  container 17881 and produce Full Muffin Crate 1839 without failure.
- Accept item 1839, give the documented reward acknowledgement, faction and
  experience, and return unrelated items through the shared helper.

## Evidence and uncertainty

[Fresh Baked Muffins (Kaladim)](https://wiki.project1999.com/Fresh_Baked_Muffins_(Kaladim))
is cached at `reference/p99-wiki/raw-pages/fresh-baked-muffins-kaladim-1aa0ae4afd.wiki`.
Its metadata records retrieval at 2026-07-17T23:15:19.721Z and SHA-256
`81a7439fbaa95c390ca888d04d996b299c3caa42bf9c52e01af5426f65431a63`.
It documents the dialogue, crate, ten baked muffins, combine, reward text,
five faction directions, experience and a reward of 7 gold.

[EQMacEmu revision b46009a](https://github.com/EQMacEmu/quests/blob/b46009ae9898d12d908a8fb9cd7f719a6ef67b20/kaladima/Gretta_Mottle.lua),
retrieved on 2026-10-21, supplies the matching IDs and implementation fallback
values. This proposal uses faction 290 +2, 312 +1, 322 -1, 293 +1 and 274 +1,
500 experience and a random 5-8 gold. P99's observed 7 gold does not prove a
fixed payout or that distribution. The exact magnitudes remain unverified.
Each muffin request offers a crate, as in the pinned EQMacEmu script. Repeat
issuance is an implementation fallback; P99 documentation does not specify
it. Item 17881 has `loregroup: -1`. The exported runtime rejects lore reward
conflicts in `reference/server/internal/quest/reward_inventory.go`, but that
settlement behavior was not executed by this source-level test.
The existing quest-only faction bypass remains intentional.

The October 3 scope reassessment reopened this quest for Classic through
Velious. Historical event timing and Gretta's day/night spawn lifecycle remain
outside this correction. The separate bread and dropped baking-supplies quests
remain incomplete. This proposal does not claim to restore those quests.
The recipe does not distinguish baked muffins from purchased muffins; the
proposal preserves the existing ingredient representation.

## Verification

Run from the content repository root with Node 22+ and Go 1.23+:

```sh
npm test
npm run validate
node tools/cli.mjs check-proposal . --proposal changes/kaladima-gretta-muffins.json
go -C validator test -run TestGrettaMuffins -v
```

The focused test executes the proposed Lua with gopher-lua v1.1.1 and the
exported `items` module. NPC and player methods are test doubles. It checks
P99 dialogue phrases and existing phrases, the crate grant and directions,
repeat full-crate offers, reward effects, unrelated-item return requests and
rejection of empty, uncombined or wrong offers.

Run the same assertions against the baseline:

```sh
GRETTA_SCRIPT=../effective/quests/kaladima/Gretta_Mottle.lua go -C validator test -run TestGrettaMuffins -v
```

The baseline fails at `P99 help phrase must offer muffin task`; the proposal
passes. The recipe's existing ingredient, container and output rows were
inspected. Only its enabled flag changes. The exact baseline evidence is:

| Record | Baseline location |
| --- | --- |
| Muffin Crate 17881, ten slots, loregroup -1 | `data/items/e.ndjson:506` |
| Muffin 13014 | `data/items/6.ndjson:185` |
| Full Muffin Crate 1839 | `data/items/3.ndjson:527` |
| Recipe container entry 150281, item 17881 | `data/tradeskill_recipe_entries/7.ndjson:1206` |
| Recipe ingredient entry 150280, item 13014, count 10 | `data/tradeskill_recipe_entries/a.ndjson:1171` |
| Recipe result entry 150282, item 1839, success count 1 | `data/tradeskill_recipe_entries/e.ndjson:1126` |

These records belong to the manifest-pinned export at commit
`b717b8a5c5dc5bd779d160b534c10329c1ae04bc`. They establish the local IDs and
recipe structure, not the game's successful execution of that recipe.

Dataset integrity and proposal syntax checks pass. Scratch MySQL rehearsal,
real game settlement and rollback, actual combine execution, spawn scheduling
and rendered UI tests have not run in this content-only environment. Source
execution is not a playable quest or complete acquisition-chain pass.
