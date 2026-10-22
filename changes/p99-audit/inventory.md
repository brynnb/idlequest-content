# P99 quest corpus inventory

Reproduce from repository root: `node tools/p99-quest-inventory.mjs . --write`. Regression tests: `node --test changes/p99-audit/inventory.test.mjs`.

## Scope and evidence

The declared 121-zone audit corpus is listed in p99_zones.json and independently bound to public exported zone rows in scope-provenance.json. It is an audit scope, not a claim of current runtime admission policy. The scope file hash is in inventory.json. No numeric IDs or expansion flags infer era. The full 1135-page preserved corpus was checked for manifest membership, title, byte length and SHA-256. No wiki requests were needed.

Inventory is exhaustive for these files, not a claim of exhaustive gameplay review. All 931 audit ledger entries and their verification caveats are retained in inventory.json. Missing Lua, enabled state and page completion are independent. Historical reviewed status does not prove rendered or connected-chain verification.

## Counts

- Perl NPC/event scripts: 3712 (3753 total Perl files including support modules); upstream Lua files: 4187; maintained Lua: 1591.
- Effective rows: 8043; P99-zone effective rows: 3431.
- Page review statuses: {"ambiguous":2,"needs_review":128,"not-recorded":206,"out_of_scope":53,"partial":11,"reviewed":735}.
- P99-zone Perl classifications: {"explicit-npc-policy":35,"explicit-quest-exclusion":59,"lua-available":1050,"unlinked-missing-lua-review":415,"wiki-linked-missing-lua-review":37}.
- All Perl classifications: {"explicit-npc-policy":35,"explicit-quest-exclusion":59,"lua-available":1050,"non-imported-version":88,"outside-p99-zone":2028,"unlinked-missing-lua-review":415,"wiki-linked-missing-lua-review":37}.

## Missing-Lua discovery leads

These 37 exact keys have no effective, maintained or eligible upstream Lua, are not explicitly quest/NPC-policy excluded, and have a normalized NPC-name link in a cached quest page. A link may name loot, merchant, flavor dialogue, an alias, or later-era behavior. It is NOT automatic conversion approval. Original Perl remains immutable. Numeric and hash-prefixed keys must not be merged. Existing Lua corrections must not be overwritten.

- cauldron/#a_cauldron_rat: Rat Ear Pie Quest. Source: sources/projecteq/cauldron/#a_cauldron_rat.pl
- cazicthule/#Avatar_of_Dread: The Summoning of Dread. Source: sources/projecteq/cazicthule/#Avatar_of_Dread.pl
- cazicthule/#Avatar_of_Fright: The Summoning of Fright. Source: sources/projecteq/cazicthule/#Avatar_of_Fright.pl
- cazicthule/#Avatar_of_Terror: The Summoning of Terror. Source: sources/projecteq/cazicthule/#Avatar_of_Terror.pl
- greatdivide/Kardakor: Ralgyn's Promise. Source: sources/projecteq/greatdivide/Kardakor.pl
- iceclad/Errgriz: Captain Nalot's Triple Strength Rum; Learn the Ways of Skinning and Tailoring. Source: sources/projecteq/iceclad/Errgriz.pl
- kael/#Valorankt_Zekkin: Coldain Ring Quests. Source: sources/projecteq/kael/#Valorankt_Zekkin.pl
- kael/Pollos_Stormkeeper: Reinforcements for The Tunarean Regiment. Source: sources/projecteq/kael/Pollos_Stormkeeper.pl
- kithicor/##a_Zombie: The Summoning of Fright; Zombie Flesh Quest. Source: sources/projecteq/kithicor/##a_Zombie.pl
- lakeofillomen/#Spirit_Sentinel: Shaman Epic Quest. Source: sources/projecteq/lakeofillomen/#Spirit_Sentinel.pl
- lakeofillomen/#tainted_barracuda: Shaman Skull Quests. Source: sources/projecteq/lakeofillomen/#tainted_barracuda.pl
- lakerathe/#tainted_aquagoblin: Druid Epic Quest. Source: sources/projecteq/lakerathe/#tainted_aquagoblin.pl
- lfaydark/Kalayia_Woodwhisper: The Summoning of Fright. Source: sources/projecteq/lfaydark/Kalayia_Woodwhisper.pl
- mischiefplane/#Bristlebane: Madame Serena Quest. Source: sources/projecteq/mischiefplane/#Bristlebane.pl
- necropolis/Neb: Key to Jaled Dar's Lair (Neb); Key to Jaled Dar's Lair (Zlandicar); Key to Sleeper's Tomb. Source: sources/projecteq/necropolis/Neb.pl
- neriaka/Hukulk: A tattered note; Bone Chips Grobb; Bone Chips Quests; Guild Summons; Guild Summons - Night Keep; Hukulk's Love. Source: sources/projecteq/neriaka/Hukulk.pl
- neriaka/Ranjor: A tattered note; Guild Summons; Guild Summons - Da Bashers; Ranjor's Test. Source: sources/projecteq/neriaka/Ranjor.pl
- skyshrine/#Kerafyrm: Essence Lens Quest. Source: sources/projecteq/skyshrine/#Kerafyrm.pl
- skyshrine/a_kromzek_spy: Hsagra's Wrath Quest. Source: sources/projecteq/skyshrine/a_kromzek_spy.pl
- skyshrine/Evreth_Menesez: Ancient Dragon Tome. Source: sources/projecteq/skyshrine/Evreth_Menesez.pl
- skyshrine/Grudash_the_Baker: Boysenberry Pie Quest. Source: sources/projecteq/skyshrine/Grudash_the_Baker.pl
- skyshrine/Ruru_the_Cook: Boysenberry Pie Quest. Source: sources/projecteq/skyshrine/Ruru_the_Cook.pl
- sleeper/#Kerafyrm_: Essence Lens Quest. Source: sources/projecteq/sleeper/#Kerafyrm_.pl
- sleeper/#Kerafyrm: Essence Lens Quest. Source: sources/projecteq/sleeper/#Kerafyrm.pl
- steamfont/Minotaur_Lord: Darkforge Armor Quests. Source: sources/projecteq/steamfont/Minotaur_Lord.pl
- templeveeshan/#Lendiniara_the_Keeper: Key to Sleeper's Tomb; Request of the Arcane; Request of the Strong; Test of the Emerald Tear; Test of the Platinum Tear; Test of the Ruby Tear. Source: sources/projecteq/templeveeshan/#Lendiniara_the_Keeper.pl
- thurgadina/Doogle_McBanick: Souvenir Mugs. Source: sources/projecteq/thurgadina/Doogle_McBanick.pl
- thurgadina/Loremaster_Fronden: Souvenir Mugs. Source: sources/projecteq/thurgadina/Loremaster_Fronden.pl
- thurgadina/Petcas_Coldbeard: Reinforcements for The Tunarean Regiment. Source: sources/projecteq/thurgadina/Petcas_Coldbeard.pl
- thurgadina/Tobart_Dirkins: Souvenir Mugs. Source: sources/projecteq/thurgadina/Tobart_Dirkins.pl
- thurgadinb/Grand_Huntsman_Darral: Tiny Savages. Source: sources/projecteq/thurgadinb/Grand_Huntsman_Darral.pl
- thurgadinb/Royal_Scribe_Kaavin: Tiny Savages. Source: sources/projecteq/thurgadinb/Royal_Scribe_Kaavin.pl
- wakening/a_tigeraptor: The Grammar Manual. Source: sources/projecteq/wakening/a_tigeraptor.pl
- wakening/a_tigesaurous: The Grammar Manual. Source: sources/projecteq/wakening/a_tigesaurous.pl
- wakening/accolyte_of_Zek: The Velium Focus. Source: sources/projecteq/wakening/accolyte_of_Zek.pl
- wakening/Bloodpriest_Ioukond: The Velium Focus. Source: sources/projecteq/wakening/Bloodpriest_Ioukond.pl
- wakening/Lady_Gelistial: Crest of the Unicorn Quest. Source: sources/projecteq/wakening/Lady_Gelistial.pl

## Missing-Lua source and NPC triage

All 452 unexcluded missing-Lua keys have source event/call extraction and verified cached NPC evidence in missing-lua-triage.json. These are discovery classifications, never completed parity reviews. Same-name Lua records are alias leads only. The 59 manually inspected Kithicor/Unrest/Cazic-Thule unlinked scripts have individual source hashes, decisions and uncertainties in manual-event-dispositions.json; generation fails if any reviewed source changed. This separates explicit Halloween/task/Beastlord content and empty handlers from genuine P99 NPC movement and unresolved revamp mechanics. No blanket zone exclusion was applied. The full bodies of all 59 were read, not sampled.

## Complete machine-readable work queue

See inventory.json: every Perl NPC/event script has an exact key, source hash, zone/version eligibility, classification, Lua availability, policy exclusion and page leads. Every declared wiki page has integrity/provenance and ledger status, including title-review candidates without ledger coverage. Unlinked missing-Lua rows require manual era/content research rather than bulk conversion; outside-zone/version rows are reference-only relative to this scope. Quest exclusions retain their reasons and reviewed_override exceptions. Support modules/plugins are listed independently in supportFiles and are not mistaken for NPC scripts. No ledger states were promoted by this report.
