# Rain Caller faction rewards

Kinool Goldsinger, NPC 62020 in `felwitheb`, awards Rain Caller without any
faction changes. P99's final hand-in lists increases to Keepers of the Art,
King Tearis Thex and Faydarks Champions, and a decrease to The Dead.

The proposal updates quest 18719, runtime key `felwitheb/Kinool_Goldsinger`,
its existing maintained override and the Rain Caller audit note. It adds
factions 275 +25, 279 +6, 246 +3 and 239 -6 only to the final hand-in. The
required items 12333, 12334 and 8401, payment of 3000 gold, reward item 8402,
5000 experience and starting-note branch stay as exported.

## Evidence and uncertainty

The final faction block in
`reference/p99-wiki/raw-pages/rain-caller-quest-c3e57fbab3.wiki`
documents all four directions. Its metadata records retrieval on
2026-07-17T23:29:23.330Z and SHA-256
`52392a824840a1873ed247f06b683461ee249576958b013f375ea9c7bc6971b1`.

P99 does not document the magnitudes. They follow the final hand-in in
[EQMacEmu revision df860b6](https://github.com/EQMacEmu/quests/blob/df860b6eb90bc11558111663fb61ae1b4493f56d/felwitheb/Kinool_Goldsinger.lua),
retrieved on 2026-10-21. These are implementation fallback values, not a
measurement of P99. The existing quest-only faction bypass remains intentional.

## Verification

From the content repository root, with Node 22+ and Go 1.23+:

```sh
npm test
npm run validate
node tools/cli.mjs check-proposal . --proposal changes/felwitheb-rain-caller-factions.json
go -C validator test -run TestRainCallerFactionRewards -v
```

The focused test executes the proposed Lua with gopher-lua v1.1.1 and the
exported `items` module. NPC and player methods are test doubles. It captures
rewards for repeated complete offers, rejects insufficient gold and missing or
wrong items, checks unrelated-item return requests, and preserves the starting
note reward. It does not exercise the game's inventory settlement or rollback.

To reproduce the missing faction reward against the exported script:

```sh
KINOOL_SCRIPT=../effective/quests/felwitheb/Kinool_Goldsinger.lua go -C validator test -run TestRainCallerFactionRewards -v
```

The baseline fails with `missing Keepers of the Art reward`; the proposal passes.
Dataset integrity and proposal syntax checks pass. Scratch MySQL rehearsal,
full IdleQuest runtime tests, and rendered UI tests have not run in this
content-only environment. No full Rain Caller acquisition-chain pass is claimed.
