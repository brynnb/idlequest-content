# Harla Dar “Seen who?” dialogue

## Change

The maintained `westwastes/Harla_Dar` script already answers “son” with the opening question, but omitted the next P99 response to “Seen who?”. This proposal adds the exact response from the cached P99 quest page. It leaves the existing hail and son dialogue, the Frakadar’s Talisman turn-in, all rewards and factions, and all other trade behavior unchanged.

## Identity and supporting content

- Zone: Western Wastes (`westwastes`).
- NPC: Harla Dar, NPC ID 120057, runtime script key `westwastes/Harla_Dar`, quest row ID 18336.
- P99 page: [Aid the Dar Brood](https://wiki.project1999.com/Aid_the_Dar_Brood), cached 2026-07-17T23:05:57.838Z, revision unavailable, SHA-256 `9aae6ec17af310834f6c78840a576a1af0219ba80239eeb29865eda5a15bb0b9`.
- NPC page: [Harla Dar](https://wiki.project1999.com/Harla_Dar), cached 2026-08-12T19:23:48.792Z, revision unavailable, SHA-256 `c4ea9e8b2fe246efe8717a8e21f2d0ae76c9255038874bf5b17bc5afedd579e9`.
- Supporting item rows exist for Frakadar’s Talisman (27260) and Shroud of the Dar Brood (27261). This is only a static existence check, not evidence that the encounter or item acquisition is playable.

## Scope and limits

This is a dialogue correction only. It does not enable a zone or NPC, prove Harla Dar’s world spawn, validate Zlandicar, talisman drop/acquisition, trade settlement, or rendered UI. The P99 page itself documents the response and the quest item/reward names. The broad quest ledger is changed to `partial` so this correction does not imply full end-to-end alignment.

The maintained source header identifies `scripts/quests/velious-backlog.mjs` and `server/internal/quest/velious_backlog_quests.json` as its generator. That input is absent from this exported repository. The IdleQuest content owner must reconcile this dialogue in the generator input during adoption or a later generation may overwrite the maintained edit.

## Verification

A focused Go test executes the Lua source and checks case-insensitive “Seen who?” variants, the existing “son” and “hail” responses, and silence for unrelated speech. It does not execute trade behavior or game settlement.
