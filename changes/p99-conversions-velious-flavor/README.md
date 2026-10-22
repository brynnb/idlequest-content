# P99 Velious flavor conversions (52 sources)

Proposal: `changes/p99-conversions-velious-flavor.json`. Exact upstream SHA256 and cached P99 NPC-presence metadata are in `review.json`. Full source event branches are preserved; undocumented dialogue wording explicitly retains upstream provenance rather than pretending to be wiki-confirmed. Added return-all item handlers never invent progression rewards. Existing Lua is not overwritten.

All 52 proposed source files and complete row preimages pass `check-proposal`; see `compiler-receipt.txt`. The shared `tools/p99-velious-flavor.test.mjs` tests both flavor proposals (57 scripts, 166 passing isolated scenarios), including every source speech/signal/combat/slay branch, unrelated triggers, arbitrary items/coins and repeat returns. Its receipt is in the main flavor directory. No test claims rendered UI, native game lifecycle, inventory rollback or full quest completion.

Main flavor review also records three unconverted NPCs: Brina has contradictory/corrupt upstream dialogue; Grudash/Ruru pie references were removed on P99 according to the cached quest page. No restored pie dialogue is proposed. See `changes/p99-conversions-velious/remaining-dispositions.json` for all200 missing Velious keys, with separate exact source anchors and open/excluded outcomes.

Baseline unchanged. Proposals only, not applied or published. Quest faction bypass and epic no-minimum-level policies unchanged.
