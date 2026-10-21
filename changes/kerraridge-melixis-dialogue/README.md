# Melixis dialogue parity

Melixis is Kerra Island NPC 74076, as identified by the cached P99 NPC page. The exported quest row is 12981 under runtime key `kerraridge/Melixis`. This proposal changes only eight `Say` strings: the hail, the shiny-rings explanation, three ring descriptions and three successful hand-in responses. It preserves all event triggers, the three offered item IDs (14042, 14043 and 14044), their ring rewards (13733, 13731 and 13732), rejected-offer behavior and every other reward.

## Evidence and scope

The cached P99 [Melixis NPC page](https://wiki.project1999.com/Melixis) identifies NPC 74076 in Kerra Island. Its cache was retrieved at `2026-08-12T20:07:20.889Z`, with SHA-256 `cc1d12b52d545548529604f3f73936c10cee98dcaef0a43a353c2506a71413ca`.

The cached P99 [Shiny Rings](https://wiki.project1999.com/Shiny_Rings) page was retrieved at `2026-07-17T23:33:11.009Z`. Its cache file is `reference/p99-wiki/raw-pages/shiny-rings-43d3e5a4f3.wiki`, with SHA-256 `669b233eb626fcb0abb01231a16cf1bec42b20cc7635a13d49e9076dd85f9b8c`. The transcript gives the eight replacement responses verbatim. Its walkthrough also lists Guk Bracket Mildew for Copper Ring, Faerix Spores for Silver Ring and Degenerated Guk Weed for Gold Ring. The matching mapping already exists in the exported script and stays unchanged.

The page shows an experience marker after each trade response but gives no amount. This proposal leaves the exported experience behavior unchanged and does not claim that its amount matches P99. It covers dialogue only, not a full quest audit or acquisition-chain validation.

## Verification

Run these checks from the repository root with Node 22+ and Go 1.23+.

```sh
npm test
npm run validate
node tools/cli.mjs check-proposal . --proposal changes/kerraridge-melixis-dialogue.json
go -C validator test -run TestMelixisDialogueAndExchanges -v
```

`MELIXIS_SCRIPT=../effective/quests/kerraridge/Melixis.lua go -C validator test -run TestMelixisDialogueAndExchanges -v` fails on the first P99 response. The default command passes.

The focused Go test executes the proposed Lua through gopher-lua and checks all eight captured responses, the three item-to-ring exchanges, a forced rejection through a `CheckHandin` test double and return of unrelated items. NPC and player methods are test doubles. The test does not exercise production inventory settlement, UI or the entire quest chain. Scratch MySQL rehearsal, full game runtime tests and rendered UI tests have not run.
