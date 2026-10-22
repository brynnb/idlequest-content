# Missing-ledger P99 page review

Review date: 2026-10-22. Source: preserved July 2026 offline corpus; original baseline unchanged.

## Result and exact boundary

All 206 raw pages with `reviewStatus: not-recorded` in the inventory now have a page-type disposition, verified raw-page SHA-256, citation, extracted item evidence when present, and links to canonical baseline ledger records and effective source identities where resolvable. Breakdown: 85 redirects, 96 item references, 18 quest indexes, five player guides, one spell reference and one historical-reference index. No new independent quest article was identified. This is not a 206-quest gameplay audit, not evidence all supplementary claims match Lua, and not full P99 parity.

`page-review.json` is supplemental review evidence, not a replacement runtime ledger. `build-review.py` regenerates classification and canonical link records without modifying the baseline. Case, apostrophes, numeric IDs, and aliases are not flattened into NPC identities. Player guides are classified before template detection because Kurrat's guide embeds both spell and item templates.

## Open embedded mechanic

Dirty Goblin Parchment has a Kunark-era book passage: visit the tribe brewer with Grinning Goblin Brew and Mt. Death Mineral Salts; brewer makes Goblin Temper. It also describes Deathsteel smithing. Items 10228 (Grinning Goblin Brew), 16972 (Mt. Death Mineral Salts), and 11595 (Goblin Temper) exist in the snapshot. Searching Droga/Nurga source/effective scripts found no exchange referencing 10228/11595. No named matching tribe brewer was resolved in the cached NPC corpus. Brewer Prixal 106096 is an Iksar merchant in East Cabilis whose cached page says no related quests; his flavor-only source is not evidence he is this goblin brewer. Do not invent an NPC, exact unspecified quantities, rewards, faction, or a Lua implementation. This item-page mechanic remains unresolved, rather than declaring every non-quest page irrelevant.

## Secondary-source disagreements and limits

- Magician Quests Checklists swaps the Earthen Boots and Robe of the Elements ingredient sets. Joyce's maintained Lua distinguishes marker/heart/soiled boots/agate -> Earthen Boots (2357) and skins/cloak/Elemental Armor -> Robe (1356). The checklist also names both Vira and Joyce under Broom of Trilon. Do not overwrite canonical quest evidence with this internally inconsistent checklist.
- Garfo's Shaman guide recommends starting at level 34 and grinding Truespirit. Those are player strategy/P99 prerequisites, not a reason to undo IdleQuest's explicit no-minimum-epic-level and quest-faction-bypass policies. Actual faction rewards remain independent.
- Rohane's Rogue guide has conflicting historical minimum-level assertions and later corrections. Those do not override the same epic exception. Its currency, milk and parchment steps remain canonical-quest review responsibilities; no comprehensive new Rogue parity claim is made here.
- Kurrat's Magician guide includes spell/effect levels 46/50, anecdotal drop frequencies and timeline-dependent earth-staff sources. Spell/item-use levels are not automatically quest-level gates. Do not turn approximate probabilities into exact loot changes. Its final reward is explicitly Spell: Summon Orb, not directly the Orb of Mastery item.
- Qeynos Leveling Quests labels its bread-shipment route temporary/removed and bandit rewards nerfed. Do not re-enable a historical event route from the guide. Use the canonical bread, bandit and rabid-animal pages for current snapshot decisions.
- Scribbled Parchment's item page links Enchanter Epic Quest; the Rogue Epic also uses that display name. Display names alone cannot choose IDs. Other note pages explicitly describe multiple same-named items.
- A Glowing Rolled-Up Note and A Tattered and Worn Note refer to seasonal/GM content, not automatic in-era implementation candidates.

## Validation

All 206 page hashes match inventory. Classifications are exhaustive and mutually exclusive. No baseline files edited; no proposed Lua change; no runtime execution, source compilation, UI interaction, or continuous-chain test performed in this supplemental pass. The broader canonical quest audit must retain its own per-facet coverage and unresolved statuses.
