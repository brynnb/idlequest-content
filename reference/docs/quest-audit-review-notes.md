# Quest audit review notes

This file tracks P99 quest-audit decisions that need human review or were intentionally not changed because the source evidence was ambiguous.

Use this alongside `server/internal/quest/content_exclusions.json`:

- `content_exclusions.json` is the machine-readable ledger for reviewed quests and disabled content.
- this file is the human-readable queue for decisions that should be reviewed before changing live quest behavior.
- `docs/quest-missing-items.md` tracks P99-relevant quest items that are missing from IdleQuest's `items` table.

## Needs review

### Independent hand-in audit — September 9, 2026

[Audit results and source ledger](quest-handin-alternatives-audit.md): 570
multi-item conditions triaged; 26 suspicious same-name sets checked against
P99. Most are genuinely complete sets. Lork's partial-heart reminder was a
related item-loss bug: it consumed a heart without saving completion credit.
The reminder now inspects without consuming, returning the original instance;
both distinct hearts still grant the existing reward. Returning partial items
is an intentional local safeguard, not an implementation of multiquest credit.
Three real Give scenarios plus GPU preflight pass; complete-set rewards are
covered by Lua bridge tests. Applied locally, not deployed.

### Ton Twostring independent mail deliveries — corrected September 9, 2026

The shipped `freportn/Ton_Twostring` script required both 18164 (issued by
Lislia Goldtune) and 18166 (issued by Idia) for one reward. Both senders describe
independent deliveries to Ton. The modified-upstream override now accepts each
separately, with one existing reward per delivery, and returns unrelated items.
Two literal hand-in branches preserve discovery of both requirements.

Provenance: vendored ProjectEQ sender/recipient scripts and the effective local
database. The preserved Going Postal wiki route table names Felisity instead
for these destinations; this correction deliberately preserves the game's
existing sender instructions and Ton recipient rather than rerouting acquired
quests. No reward-value or later-era Freeport changes are included.

`TestTonAcceptsIndependentMailDeliveries` reproduces the old rejection, then
checks each pouch, both together, unrelated/wrong-destination items, rewards,
and requirement discovery through the real Lua bridge. Applied with the
single-override importer to the local database only. The actual Give-window
suite now passes each pouch, both together, and mail plus an unrelated item
(four scenarios plus GPU preflight, 50 seconds). The rendered result was
inspected before test cleanup. Production deployment has not been performed.
See [the alternatives audit](quest-handin-alternatives-audit.md) for the wider
candidate review, source distinctions, and additional mail/scroll regressions.

### Temple Blankets Minya Coldtoes gap

- P99 page: `https://wiki.project1999.com/Temple_Blankets_Quest`
- Local quest keys: `qeynos/Chesgard_Sydwen`, `qey2hh1/Rongol`, `qey2hh1/Tukk`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/qeynos/Chesgard_Sydwen.lua`, `server/internal/quest/upstream/projecteq/qey2hh1/Rongol.lua`, `server/internal/quest/upstream/projecteq/qey2hh1/Tukk.lua`
- Status: Chesgard, Rongol, and Tukk steps are enabled; no Minya Coldtoes script was added.

P99 documents the Rongol and Tukk blanket turn-ins but says Minya's dialogue/details still need to be gathered. Local data has a `Minya_Coldtoes` NPC row but no confirmed P99 dialogue or reward path.

Decision for now: do not invent Minya behavior. Keep the confirmed blanket steps enabled and revisit Minya only if a stronger classic/P99 source appears.

### Tergon's Spellbook unspecified final scroll reward

- P99 page: `https://wiki.project1999.com/Tergon%27s_Spellbook_Quest`
- Local quest keys: `akanon/Tergon_Brenclog`, `crushbone/Retlon_Brenclog`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/akanon/Tergon_Brenclog.lua`, `server/internal/quest/overrides/lua/modified-upstream/crushbone/Retlon_Brenclog.lua`
- Status: Retlon's sealed-letter faction was corrected; Tergon's spellbook hand-in still gives faction and experience but no final item.

P99 says returning Tergon's Spellbook gives experience and "an item, usually a scroll," but the page's newer transcript does not identify a concrete reward item. Local upstream had the final dialogue/faction/experience but no scroll item.

Decision for now: do not guess a spell scroll. Keep the quest mechanically completable for faction/experience and revisit when a confirmed P99 reward item or reward pool is found.

### Terrorantula Quest unsolved/no reward path

- P99 page: `https://wiki.project1999.com/Terrorantula_Quest`
- Local quest keys: `misty/Blixkin_Entopop`, `mistythicket/Blixkin_Entopop`
- Local files: `server/internal/quest/overrides/lua/converted-perl/misty/Blixkin_Entopop.lua`, `server/internal/quest/overrides/lua/converted-perl/mistythicket/Blixkin_Entopop.lua`
- Status: Blixkin's existing bug-collection script is available in both local zone aliases; no Terrorantula turn-in was added.

P99 marks this page unsolved and says Terrorantula leg hand-in produced no dialogue or acknowledgement aside from consuming the item.

Decision for now: do not add a Terrorantula reward or item-eating trap. Revisit only if a confirmed P99 solution exists.

### The Bayle List alternate Dyllin path

- P99 page: `https://wiki.project1999.com/The_Bayle_List`
- Local quest keys: `qcat/Commander_Kane`, `highpass/Barn_Bloodstone`, `qrg/Mammoth`, `qrg/Frenway_Marthank`, `highpass/Dyllin_Starsine`, `southro/Rathmana_Allin`, `freeporteast/Pietro_Zarn`
- Status: all three list pieces are obtainable through kill/drop or delivery paths, Rathmana translates the list, and Pietro rewards Rage War Maul.

P99 says Bayle List III can be obtained by killing Dyllin or, with high faction/influence, by getting him to give it up. The local script supports killing Dyllin for the list but does not implement the high-faction non-kill handoff.

Decision for now: keep the working kill/drop path and do not guess the high-faction dialogue/state. Revisit if exact Dyllin handoff text and faction requirements are found.

### Tomer's Rescue escort simplification

- P99 page: `https://wiki.project1999.com/Tomer%27s_Rescue`
- Local quest keys: `qeynos2/Seta_Bakindo`, `qeynos2/Tomer_Instogle`
- Local files: `server/internal/quest/overrides/lua/converted-perl/qeynos2/Seta_Bakindo.lua`, `server/internal/quest/overrides/lua/converted-perl/qeynos2/Tomer_Instogle.lua`
- Status: stateful dialogue and final backpack turn-in are playable; physical NPC escort movement is simplified.

P99 has Tomer physically follow the player back to Seta before the final backpack hand-in. IdleQuest currently treats `eq.follow`/`eq.stop_follow` as runtime compatibility no-ops. The converted script previously used `eq.target_global`, which was also a no-op in the bridge, so the rescue flags would not persist.

Decision for now: use supported `eq.set_global` state so the Seta/Tomer dialogue and final backpack turn-in work, but do not implement true NPC following as part of this quest-audit batch.

### Tonics for Groflah coin reward variance

- P99 page: `https://wiki.project1999.com/Tonics_for_Groflah`
- Local quest keys: `freeporteast/Groflah_Steadirt`, `freporte/Groflah_Steadirt`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/freeporteast/Groflah_Steadirt.lua`, `server/internal/quest/overrides/lua/modified-upstream/freporte/Groflah_Steadirt.lua`
- Status: local Freeport alias overrides now reward coin.

P99 lists the reward as faction plus 1-3 gold pieces, but does not document exact odds. Local upstream rewarded faction and experience but no coin.

Decision for now: award a random 1, 2, or 3 gold for each Tumpy Tonic hand-in and keep the existing faction/experience behavior.

### Tunare Symbol Warden continuation cutoff

- P99 page: `https://wiki.project1999.com/Tunare_Symbol_Quests`
- Local quest keys: `felwithea/Yeolarn_Bronzeleaf`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/felwithea/Yeolarn_Bronzeleaf.lua`
- Status: Initiate and Disciple Symbol steps remain enabled; Warden Symbol branch removed from Yeolarn.

P99 marks the overall Tunare Symbol page as Kunark Era, but the Warden Symbol subsection is explicitly marked Warrens Era. IdleQuest's current content scope is Classic/Kunark, excluding Warrens-era additions.

Decision for now: keep the Initiate and Disciple symbol steps, remove Yeolarn's Warden dialogue/Black Stone Candlestick handout/final Powder of Unanimation turn-in, and leave Trilani's separate script alone because it also contains Mystic Cloak behavior.

### The Bloody Shank Bronin bodyguard variance

- P99 page: `https://wiki.project1999.com/The_Bloody_Shank`
- Local quest keys: `highkeep/Captain_Boshinko`, `misty/Bronin_Higginsbot`, `mistythicket/Bronin_Higginsbot`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/highkeep/Captain_Boshinko.lua`, `server/internal/quest/overrides/lua/converted-perl/misty/Bronin_Higginsbot.lua`, `server/internal/quest/overrides/lua/converted-perl/mistythicket/Bronin_Higginsbot.lua`
- Status: Bronin now attacks on Bloody Shank hand-in and Boshinko's reward was aligned to the P99 reward description.

P99 says a bodyguard sometimes spawns next to Bronin when handing him the Bloody Shank. It does not give exact conditions or a guaranteed spawn rule.

Decision for now: make Bronin attack, but do not add a guessed bodyguard spawn. Revisit if a clear spawn condition/source is found.

### Solvedi Scimitar dialogue-state requirement

- P99 page: `https://wiki.project1999.com/Solvedi_Scimitar_Quest`
- Local quest key: `rathemtn/Solvedi_Aldeberan`
- Local file: `server/internal/quest/overrides/lua/converted-perl/rathemtn/Solvedi_Aldeberan.lua`
- Status: core hand-in and source drops are available.

P99 warns that players must hail Solvedi and follow the dialogue until he offers his weapon as the reward; otherwise handing in one item can eat it with no reward. The local Lua accepts the complete Giant Laceless Sandal + Lionhide Backpack hand-in directly.

Decision for now: keep the safe direct complete hand-in and do not add punitive dialogue-state item loss. Revisit if IdleQuest later intentionally models these P99 one-shot dialogue-state traps.

### Shaman Plane of Sky starter tome flow

- P99 page: `https://wiki.project1999.com/Shaman_Plane_of_Sky_Tests`
- Local quest keys: `airplane/Medicine_Man_Veetra`, `airplane/Gina_McStargan`, `airplane/Ooga`
- Local files: `server/internal/quest/upstream/projecteq/airplane/Medicine_Man_Veetra.lua`, `server/internal/quest/overrides/lua/modified-upstream/airplane/Gina_McStargan.lua`, `server/internal/quest/upstream/projecteq/airplane/Ooga.lua`
- Status: Gina's Test of Might reward was corrected from the old Drake Fang Amulet to P99's Amulet of the Fang.

P99 documents Medicine Man Veetra giving a tome that is returned to summon Gina or Ooga. Local Medicine Man Veetra directly spawns the selected tester from dialogue, which is the same simplified Plane of Sky starter pattern already present for other class tests.

Decision for now: keep direct tester spawning and match the actual test hand-ins/rewards. Revisit only if exact Plane of Sky starter-state fidelity becomes important.

### Shaman Skull Quests cutoff after #5

- P99 page: `https://wiki.project1999.com/Shaman_Skull_Quests`
- Local quest keys: `cabeast/Hierophant_Dexl`, `cabeast/Hierophant_Granix`, `cabeast/Hierophant_Zand`
- Local files: `server/internal/quest/content_exclusions.json`, `server/internal/quest/overrides/lua/modified-upstream/cabeast/Hierophant_Zand.lua`
- Status: Hierophant Dexl and Hierophant Granix are disabled as later-era continuations; Zand's #5 completion no longer points players into those continuations.

P99 explicitly notes that only the first five Shaman Skull quests exist on Project 1999 and that the remaining quests were not added until Luclin. Local upstream had #6 and #7 enabled in East Cabilis.

Decision for now: support only P99 skull quests #1-#5 for Classic/Kunark IdleQuest and exclude later cudgel continuations.

### Shiny Robe of the Underfoot reward odds and charm behavior

- P99 page: `https://wiki.project1999.com/Shiny_Robe_of_the_Underfoot_Quest`
- Local quest key: `hole/Kejar_the_Mighty`
- Local file: `server/internal/quest/overrides/lua/converted-perl/hole/Kejar_the_Mighty.lua`
- Status: Kejar now weights Shiny Hunk of Metal as the more common reward.

P99 says Shiny Hunk of Metal is more common than Shiny Robe of the Underfoot but does not provide exact odds. The page also has uncertain notes about Kejar needing charm for the turn-in and eating the robe when mezzed.

Decision for now: use an approximate weighted reward pool and do not model charm/mezz turn-in state. Revisit if stronger evidence gives exact odds or if IdleQuest later supports charm-required NPC turn-ins.

### Scroll of G'han classically broken dialogue

- P99 page: `https://wiki.project1999.com/Scroll_of_G%27han`
- Local quest key: `neriakc/Noxhil_V-Sek`
- Local file: `server/internal/quest/overrides/lua/converted-perl/neriakc/Noxhil_V-Sek.lua`
- Status: Noxhil now exposes the P99 Innoruuk / scroll dialogue with the documented faction gate.

P99 marks this as unfinished/not implemented until much later after classic. It documents dialogue only and no valid classic reward path.

Decision for now: preserve the classic dialogue but do not add a completion path or later-era quest reward.

### Sentry Xyrin escort and ground-drop fidelity

- P99 page: `https://wiki.project1999.com/Sentry_Xyrin_Quest`
- Local quest keys: `freportn/Serna_Tasknon`, `freportn/Sentry_Andlin`, `freportn/Sentry_Boris`, `freportn/Sentry_Gallius`, `freportn/Sentry_Janeal`, `freportn/Sentry_Meighan`, `freportn/Sentry_Theo`, `freportn/Sentry_Warren`, `oot/Styria_Fearnon`, `oot/Sentry_Xyrin`
- Local file changed: `server/internal/quest/overrides/lua/modified-upstream/oot/Sentry_Xyrin.lua`
- Status: the Potion of Marr hand-in sequence now starts Xyrin's undead-island event from the final potion hand-in instead of from dialogue.

P99 documents a roughly six-minute defense/escort where Xyrin drops Deepwater Harpoon at her final location. The local script uses the existing waypoint path and creates the harpoon ground object at a fixed waypoint coordinate. This makes the quest mechanically reachable, but it does not prove exact P99 timing, combat, or dynamic ground-drop location behavior.

Decision for now: correct the hand-in trigger and keep the existing waypoint/ground-object approximation. Revisit only if exact escort behavior becomes important.

### Scrap Metal Quest reward table

- P99 page: `https://wiki.project1999.com/Scrap_Metal_Quest`
- Local quest key: `akanon/Sanfyrd_Featherhead`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/akanon/Sanfyrd_Featherhead.lua`
- Status: Tinmizer's Stupendous Contraption was removed from the random reward pool because P99 says it no longer drops on Blue/Green; P99-listed Earring of Fire Reflection and Small Scarab Helm were added.

P99 documents "Small Coin, Minor Items" but does not give exact coin odds. The local script previously granted one platinum on every four-scrap turn-in, which is inconsistent with "small coin."

Decision for now: remove the platinum coin while preserving a small local coin reward. Revisit if a P99-confirmed coin table is found.

### The Test of the Green and Blue removed reward path

- P99 page: `https://wiki.project1999.com/The_Test_of_the_Green_and_Blue`
- Local quest keys: `freportw/Cain_Darkmoore`, `freeporteast/Cain_Darkmoore`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/freportw/Cain_Darkmoore.lua`, `server/internal/quest/upstream/projecteq/freeporteast/Cain_Darkmoore.lua`
- Status: Cain's dialogue remains available, but no Bunker Battle Blade completion path exists.

P99 says this quest's current status is unknown and notes it was apparently removed very early in classic. The documented current dialogue says Cain has no more bunker battle blades to spare.

Decision for now: keep the refusal/dialogue only and do not add the old shoulderpad turn-in reward path unless stronger P99-era evidence says it should be playable in IdleQuest.

### Thex Dagger removed branch versus Silent Watch Shield branch

- P99 page: `https://wiki.project1999.com/Thex_Dagger_Quest`
- Local quest keys: `highkeep/Tearon_Bleanix`, `felwithea/Inkeeper_Freegraze`, `felwithea/Tolon_Nurbyte`, `lakerathe/Princess_Lenya_Thex`
- Local files: `server/internal/quest/upstream/projecteq/highkeep/Tearon_Bleanix.lua`, `server/internal/quest/upstream/projecteq/felwithea/Inkeeper_Freegraze.lua`, `server/internal/quest/upstream/projecteq/felwithea/Tolon_Nurbyte.lua`, `server/internal/quest/overrides/lua/converted-perl/lakerathe/Princess_Lenya_Thex.lua`
- Status: the exact P99 Thex Dagger chain is not enabled locally.

P99 explicitly says the Thex Dagger quest was removed with Temple Era in October 1999, but legacy sealed letters can still be handed to Tolon Nurbyte for Thex Dagger. Local ProjectEQ-derived scripts around Princess Lenya and Tearon currently implement the related Silent Watch Shield/Royal Amulet path instead of the removed Thex Dagger sealed-letter branch.

Decision for now: document the mismatch and leave the exact removed branch disabled. Do not rewrite the active Silent Watch Shield path into the removed Thex Dagger path without a specific design decision that IdleQuest should include this removed-era quest.

### Tinmizer's Fabulous Compactor legacy source

- P99 page: `https://wiki.project1999.com/Tinmizer%27s_Fabulous_Compactor_(Quest)`
- Local quest keys: `akanon/Kozyn_Gigglephizz`, `akanon/Sanfyrd_Featherhead`
- Local files: `server/internal/quest/overrides/lua/idlequest-authored/akanon/Kozyn_Gigglephizz.lua`, `server/internal/quest/overrides/lua/modified-upstream/akanon/Sanfyrd_Featherhead.lua`
- Status: Kozyn now supports the legacy Tinmizer container hand-in, but Scrap Metal still does not award the source item.

P99 says the compactor no longer drops on Blue/Green. Local item data has `Tinmizer's Stupendous Contraption` item `17033`, and earlier Scrap Metal cleanup removed it from Sanfyrd's reward pool.

Decision for now: keep the source item unavailable from Scrap Metal while allowing Kozyn to exchange an existing legacy/local compactor item for Lapis Lazuli.

### Shadow Knight Plane of Sky starter flow

- P99 page: `https://wiki.project1999.com/Shadow_Knight_Plane_of_Sky_Tests`
- Local quest keys: `airplane/Sarkis_Ebonblade`, `airplane/Gragrot`, `airplane/Tynicon_DLin`
- Local files changed: `server/internal/quest/overrides/lua/modified-upstream/airplane/Gragrot.lua`, `server/internal/quest/overrides/lua/modified-upstream/airplane/Tynicon_DLin.lua`
- Status: Gragrot and Tynicon reward item IDs were corrected to P99 for Amulet of the Sphinx Eye, Crimson Ring of the Djinni, and Khyldorn the Blood Drinker.

Local Sarkis directly spawns Gragrot or Tynicon from dialogue. P99 documents a book handoff/return before the tester is summoned. This is the same simplified Plane of Sky starter pattern already recorded for other class Sky tests.

Decision for now: keep direct tester spawning and match the actual test turn-ins/rewards.

### Sebilis and Veeshan's Peak Key aggregate page

- P99 page: `https://wiki.project1999.com/Sebilis_and_Veeshan%27s_Peak_Key_Quest`
- Local quest key: `trakanon/Emperor_Ganak`
- Local file: `server/internal/quest/overrides/lua/converted-perl/trakanon/Emperor_Ganak.lua`
- Status: Emperor Ganak's Sebilis and Veeshan's Peak final key turn-ins match P99.

This P99 page also lists multiple child medallion quests. Those child pages already have individual audit ledger entries, including Burnished Wooden Staff Quest, Medallion of the Jarsath Quest, Medallion of the Obulus Quest, Medallion of the Kylong Quest, and Niblek's Gems.

Decision for now: treat this aggregate page as reviewed for the final Emperor Ganak hand-ins and rely on the child-page audit entries for the medallion procurement chains.

### Shakey the Scarecrow's Head classic-broken endpoint

- P99 page: `https://wiki.project1999.com/Shakey_the_Scarecrow%27s_Head`
- Local quest keys: `rivervale/Shakey_Scarecrow`, `rivervale/Reebo_Leafsway`, `erudnext/Sornita_Eltern`
- Local files changed: `server/internal/quest/overrides/lua/modified-upstream/rivervale/Shakey_Scarecrow.lua`, `server/internal/quest/overrides/lua/modified-upstream/rivervale/Reebo_Leafsway.lua`
- Status: classic lead-in dialogue and Sornita's Torn Parchment step are enabled, while the later Fatestealer/Dilapidated Head branch remains omitted.

P99 marks this quest as classically broken and impossible to complete. The later solved version belongs to Rogue Epic 1.5 era, outside IdleQuest's current Classic/Kunark quest scope.

Decision for now: preserve the visible P99 lead-in and the Torn Parchment step, but do not add a completion path or later-era Shakey head reward.

### Rogue Redemption full-chain fidelity

- P99 page: `https://wiki.project1999.com/Rogue_Redemption`
- Local quest keys: `soltemple/Lon_the_Redeemed`, `cauldron/Conium_Darkblade`, `highpass/Bryan_McGee`, `southro/Ortallius`, `sro/Ortallius`, `commons/Noresa_Sparkle`, `commons/Kizdean_Gix`, `freeporteast/Toxdil`, `freportw/Toxdil`, `ecommons/Bubar`
- Status: local Lua coverage exists for the core Rogue Redemption chain, but the page has not received the same dedicated end-to-end audit as the Rogue Epic fixture.

The P99 page is a large multi-zone chain with several intermediate item exchanges and optional dialogue/context NPCs. This batch confirmed that the local scripts exist for the major hand-in spine, but it did not prove every P99 dialogue line, side branch, faction amount, or intermediate item source.

Decision for now: keep the chain enabled, but do not mark it fully P99-aligned until it gets a dedicated chain audit and, ideally, runnable fixture coverage.

### Scaled Mystic Armor payment-state behavior

- P99 page: `https://wiki.project1999.com/Scaled_Mystic_Armor_Quests`
- Local quest keys: `cabeast/Shezlie_Furscale`, `cabeast/Zazlan_Furscale`
- Local files: `server/internal/quest/overrides/lua/converted-perl/cabeast/Shezlie_Furscale.lua`, `server/internal/quest/overrides/lua/converted-perl/cabeast/Zazlan_Furscale.lua`
- Migration: `server/migrations/092_add_p99_rogue_scaled_mystic_sources.sql`
- Status: both armor NPCs now have Lua turn-ins, and Watchman's Spectacles was added to Raider Watchman loot.

P99 notes that players should say `payment` as the final dialogue keyword before handing in armor components, or the NPC may eat the items. The local ProjectEQ Perl scripts did not model that state; the restored Lua accepts complete hand-ins directly.

Decision for now: prioritize making the armor quests completable and source-correct. Do not intentionally add punitive item-loss state until the user explicitly wants that level of P99 dialogue-state fidelity.

### Rogue Plane of Sky starter flow

- P99 page: `https://wiki.project1999.com/Rogue_Plane_of_Sky_Tests`
- Local quest keys: `airplane/Thalik_Silenthand`, `airplane/Kendrick`, `airplane/Rayne`
- Local files: `server/internal/quest/upstream/projecteq/airplane/Thalik_Silenthand.lua`, `server/internal/quest/upstream/projecteq/airplane/Kendrick.lua`, `server/internal/quest/overrides/lua/modified-upstream/airplane/Rayne.lua`
- Status: Rayne's Cunning and Deception rewards were corrected to the P99 Crystal Mask and Thornstinger item rows.

Local Thalik directly spawns Rayne or Kendrick from dialogue. P99 Plane of Sky class-test pages commonly document a more formal tester handoff flow, but prior audit batches have accepted direct tester spawning as the current IdleQuest-compatible Sky starter pattern.

Decision for now: keep direct tester spawning and match the actual test turn-ins/rewards.

### Rohand's Brandy local Coalition faction ID

- P99 page: `https://wiki.project1999.com/Rohand%27s_Brandy`
- Local quest key: `qeynos/Captain_Rohand`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/qeynos/Captain_Rohand.lua`
- Status: Rohand now uses the P99 faction directions and approximate documented amounts.

P99 labels the small positive faction as Coalition of Tradefolk. In local data, faction ID `336` is Coalition of Tradefolk Underground, while ID `5015` is Coalition of TradeFolk III. The corrected Lua uses `5015` to avoid granting the underground/rogue faction on a Qeynos merchant quest.

Decision for now: treat `5015` as the intended local equivalent for this page unless a future faction-data audit proves a better mapping.

### Noble Hunters parchment/scalp follow-up identity

- P99 page: `https://wiki.project1999.com/Noble_Hunters`
- Local quest key: `oggok/Guntrik`
- Local file: `server/internal/quest/overrides/lua/converted-perl/oggok/Guntrik.lua`
- Migration: `server/migrations/087_add_noble_hunters_crest_drops.sql`
- Status: Guntrik's dialogue and Noble's Crest turn-in were restored; Noble's Crest drops were made available on local noble hunter variants.

P99 also documents a Tattered Parchment lead-in and a final two-Human-Scalp hand-in for Ogre War Maul. The cached P99 `Tattered Parchment` item page corresponds to the rogue/treant item, and local ProjectEQ Guntrik source only implemented the Noble's Crest branch. Local DB has generic `Scalp` item `14162`, but no clear Human Scalp item/drop evidence on Sven Drinn or Philicia Drinn.

Decision for now: implement the confirmed Noble's Crest portion and source item, but do not guess parchment/scalp item IDs or Drinn drops. Revisit when a classic source identifies the exact items for Guntrik's follow-up.

### Orc Runner (Kelethin) pouch coin variance

- P99 page: `https://wiki.project1999.com/Orc_Runner_(Kelethin)`
- Local quest key: `gfaydark/Dill_Fireshine`
- Local file: `server/internal/quest/overrides/lua/converted-perl/gfaydark/Dill_Fireshine.lua`
- Status: Dill's runner rewards were adjusted away from PEQ's 9g-2p cash range.

P99 lists the Runner Pouch reward item pool as Longbow, Rusty Short Sword, Rusty Spear, Rusty Two Handed Sword, and Tarnished Bastard Sword. It gives two coin datapoints for the pouch branch: 12 copper, and 4g/4s/9c with a Rusty Two Handed Sword. It gives a clearer 1p/15s reward for the Sealed Letter branch.

Decision for now: use the P99 weapon pool, make the two documented pouch coin datapoints possible, and set the Sealed Letter coin to 1p/15s. Revisit if stronger P99-era data gives the actual random cash table.

### Odd Items likely dialogue-only page

- P99 page: `https://wiki.project1999.com/Odd_Items`
- Local quest key: `firiona/Guard_Frandan`
- Status: no local quest script was added.

P99 documents Guard Frandan dialogue about giants carrying odd items, but the page says Kromdul Toothpick hand-in returns nothing and the author does not think this is an actual quest.

Decision for now: do not invent a reward or local turn-in. Treat this as dialogue/flavor until a confirmed P99 quest solution exists.

### Old Dreams out-of-scope holiday/Eastern Wastes page

- P99 page: `https://wiki.project1999.com/Old_Dreams`
- Local quest key: `eastwastes/Dreamspeaker_Lyssiara`
- Status: no local script exists.

P99's page is based in Eastern Wastes and requires Holiday Gift plus a reward item not present in IdleQuest's item table. This is outside the current Classic/Kunark playable-content scope.

Decision for now: mark the P99 page out of scope and make no local content change.

### Mooto's Proof unsolved P99 page

- P99 page: `https://wiki.project1999.com/Mooto%27s_Proof`
- Local quest key: `misty/Mooto`
- Status: no local quest script was added.

P99 marks Mooto's Proof as unsolved. The page documents Mooto's orc-camp line and a wolf-form hail line, but it explicitly says Deathfist Slashed Belt and Pawn Scalp did not produce a result and asks for the missing solution/reward.

Decision for now: do not invent a turn-in or reward. Local has Mooto NPC rows but no quest script. Revisit only if a confirmed P99 solution source is found.

### Necro Spells Keeper Bile exact faction/EXP amounts

- P99 page: `https://wiki.project1999.com/Necro_Spells`
- Local quest key: `cabwest/Keeper_Bile`
- Local file: `server/internal/quest/overrides/lua/converted-perl/cabwest/Keeper_Bile.lua`
- Status: Keeper Bile now requires two Brittle Iksar Skulls, one Sabertooth Cub Canine, and one Large Scorpion Pincer.

P99 documents positive Brood of Kotiz and Legion of Cabilis faction directions, experience, coin, and a random low-level necromancer spell reward, but it does not provide exact numeric faction amounts or a precise spell table on the page.

Decision for now: keep the existing local random low-level necromancer spell pool, add conservative positive Brood of Kotiz and Legion of Cabilis hits, and keep a small local EXP value. Revisit only if exact P99 amounts or reward-pool evidence is found.

### Necromancer Epic Plane of Sky side effects and simplified dialogue

- P99 page: `https://wiki.project1999.com/Necromancer_Epic_Quest`
- Local quest keys: `nektulos/Venenzi_Oberzendi`, `lakerathe/Kazen_Fecae`, `lakerathe/Emkel_Kabae`, `swampofnohope/Ssessthrass`, `timorous/Drendico_Metalbones`, `airplane/Jzil_GSix`, `airplane/a_thunder_spirit_princess`, `airplane/Gkzzallk`
- Local files: `server/internal/quest/overrides/lua/converted-perl/nektulos/Venenzi_Oberzendi.lua`, `server/internal/quest/overrides/lua/converted-perl/lakerathe/Kazen_Fecae.lua`, `server/internal/quest/overrides/lua/converted-perl/lakerathe/Emkel_Kabae.lua`, `server/internal/quest/overrides/lua/converted-perl/swampofnohope/Ssessthrass.lua`, `server/internal/quest/overrides/lua/converted-perl/timorous/Drendico_Metalbones.lua`, `server/internal/quest/upstream/projecteq/airplane/Jzil_GSix.lua`, `server/internal/quest/overrides/lua/modified-upstream/airplane/a_thunder_spirit_princess.lua`, `server/internal/quest/upstream/projecteq/airplane/Gkzzallk.lua`
- Status: the required same-player item hand-in path exists; Thunder Spirit Princess currency turn-in was fixed; Kazen death now triggers the bone-golem chain.

The local Necromancer Epic scripts intentionally use much shorter dialogue than P99's page. P99 also documents Plane of Sky raid-side effects around spawning Gkzzallk, including disrupting the Thunder Spirit Princess/Sirran flow. Local now spawns Gkzzallk from the 10-gold hand-in, but it does not model every Plane of Sky raid scheduling side effect.

Decision for now: prioritize the epic's item chain and required quest-spawn mechanics over exact raid-side-effect simulation. Revisit if Plane of Sky shared-raid behavior becomes in scope for IdleQuest.

### Necromancer Plane of Sky starter flow

- P99 page: `https://wiki.project1999.com/Necromancer_Plane_of_Sky_Tests`
- Local quest keys: `airplane/Drakis_Bloodcaster`, `airplane/Jzil_GSix`, `airplane/Dugaas_Helpyre`
- Local files: `server/internal/quest/upstream/projecteq/airplane/Drakis_Bloodcaster.lua`, `server/internal/quest/upstream/projecteq/airplane/Jzil_GSix.lua`, `server/internal/quest/overrides/lua/modified-upstream/airplane/Dugaas_Helpyre.lua`
- Status: Jzil and Dugaas direct test hand-ins match the P99 item/reward sets.

P99 documents a Drakis Bloodcaster book-handoff flow and trade-back dialogue before summoning Jzil or Dugaas. Local Drakis directly spawns the selected tester from dialogue, which is simpler but preserves access to the actual test NPCs.

Decision for now: keep the direct tester-spawn flow and treat exact Plane of Sky book-handoff behavior as a review item unless Sky starter fidelity becomes gameplay-critical.

### Necromancer Skullcap rank 8 and post-P99 continuation rows

- P99 page: `https://wiki.project1999.com/Necromancer_Skullcap_Quests`
- Local quest keys: `cabwest/an_Iksar_hermit`, `overthere/Ixpacan`
- Status: these continuation rows are explicitly excluded from imported quest content.

P99 documents the 8th-rank Necromancer Skullcap as impossible to complete because the required later-era hair/lock does not drop on Project 1999. Local also had a later Ixpacan/Demi Lich Skullcap continuation using 48000-series items that is outside the achievable P99 Skullcap chain.

Decision for now: keep Skullcap ranks 1 through 7 functional, disable the stale rank-8 hermit row, and disable Ixpacan's later continuation row. Revisit only if IdleQuest intentionally expands beyond P99-achievable Classic/Kunark skullcap behavior.

### Necromancer Skullcap exact faction threshold for Harbinger Glosk

- P99 page: `https://wiki.project1999.com/Necromancer_Skullcap_Quests`
- Local quest key: `cabwest/Harbinger_Glosk`
- Local file: `server/internal/quest/overrides/lua/converted-perl/cabwest/Harbinger_Glosk.lua`
- Status: Harbinger Glosk now requires kindly-or-better faction for the seventh-rank `new revenant` prompt.

P99 says Kindly Brood of Kotiz faction is required to receive the Unfinished Sceptre. IdleQuest gates this by faction-con bucket rather than exact raw faction points.

Decision for now: use Kindly or better for the prompt and leave exact within-con faction nuance out of scope.

### Monk headband faction threshold

- P99 page: `https://wiki.project1999.com/Monk_Headband_Quests`
- Local quest keys: `qeynos2/Phin_Esrinap`, `qeynos2/Togahn_Sorast`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/qeynos2/Phin_Esrinap.lua`, `server/internal/quest/overrides/lua/modified-upstream/qeynos2/Togahn_Sorast.lua`
- Status: Phin and Togahn now require Silent Fist kindly-or-better faction for their headband turn-ins and return items on rejection.

P99's page introduction says players need Kindly faction with Silent Fist, while a later faction note says "high amiably" may be sufficient. IdleQuest's quest bridge exposes faction-con buckets for this check, not raw within-bucket values.

Decision for now: gate the turn-ins at Kindly or better, matching the explicit P99 intro wording and avoiding a hidden high-Amiably threshold that the current quest runtime cannot represent directly.

### Monk sash exact faction threshold

- P99 page: `https://wiki.project1999.com/Monk_Sash_Quests`
- Local quest keys: `freportw/Velan_Torresk`, `freeportwest/Velan_Torresk`, `freportw/Reyia_Beslin`, `freeportwest/Reyia_Beslin`
- Local files: `server/internal/quest/upstream/projecteq/freportw/Velan_Torresk.lua`, `server/internal/quest/upstream/projecteq/freeportwest/Velan_Torresk.lua`, `server/internal/quest/overrides/lua/modified-upstream/freportw/Reyia_Beslin.lua`, `server/internal/quest/overrides/lua/modified-upstream/freeportwest/Reyia_Beslin.lua`
- Status: Reyia Beslin now uses the same kindly-or-better turn-in rejection behavior already present on Velan Torresk.

P99 documents orange/red sash faction requirements with both high-Amiably wording and an at-least-Kindly note. IdleQuest currently checks the faction-con bucket rather than exact raw faction points.

Decision for now: use Kindly or better for both Freeport monk sash quest NPCs so the documented faction gate exists and stays consistent across the chain.

### Monk Plane of Sky item aliases and simplified Holwin flow

- P99 page: `https://wiki.project1999.com/Monk_Plane_of_Sky_Tests`
- Local quest keys: `airplane/Holwin`, `airplane/Ton_Po`, `airplane/Wu_the_Enlightened`
- Local files: `server/internal/quest/upstream/projecteq/airplane/Holwin.lua`, `server/internal/quest/overrides/lua/modified-upstream/airplane/Ton_Po.lua`, `server/internal/quest/overrides/lua/modified-upstream/airplane/Wu_the_Enlightened.lua`
- Migration: `server/migrations/082_add_monk_sky_brass_knuckles_drop.sql`
- Status: Ton Po and Wu rewards were updated to the current P99 item IDs, and Brass Knuckles was added to the P99-listed Plane of Sky boss loot sources.

The current P99 page names `Back Straps of Mastery` item `27714` and `Wu's Fist of Mastery` item `27715`. Older Sky documentation also shows aliases for these slots, including `Mystical Back Straps` and `Wu's Tranquil Fist`, which were the local rewards before this audit.

Holwin's local script still uses a simplified tester-spawn flow instead of reproducing the full P99 book handoff structure. This keeps the tests playable, but it is not a perfect dialogue/flow match.

Decision for now: use the current P99 reward item IDs for the actual hand-in rewards, add the missing Brass Knuckles source, and leave Holwin's simplified flow as a review item unless exact Plane of Sky starter behavior becomes important for gameplay.

### Monks of The Whistling Fist multiquest support

- P99 page: `https://wiki.project1999.com/Monks_of_The_Whistling_Fist`
- Local quest keys: `southkarana/#Brother_Qwinn`, `rathemtn/Brother_Zephyl`
- Local files: `server/internal/quest/overrides/lua/converted-perl/southkarana/#Brother_Qwinn.lua`, `server/internal/quest/overrides/lua/converted-perl/rathemtn/Brother_Zephyl.lua`
- Status: direct same-player Brother Qwinn and Brother Zephyl hand-ins match the P99 chain.

P99 documents successful multiquest behavior for Brother Qwinn. IdleQuest's quest turn-in runtime currently evaluates complete same-player item sets and does not model original-EQ multiquest hand-ins across multiple players.

Decision for now: keep direct hand-ins working and document multiquest support as out of scope for the current solo-first questing model.

### Monk epic wrong-Kaiaren final hand-in behavior

- P99 page: `https://wiki.project1999.com/Monk_Epic_Quest`
- Local quest keys: `trakanon/Kaiaren`, `trakanon/#Kaiaren`
- Local files: `server/internal/quest/overrides/lua/converted-perl/trakanon/Kaiaren.lua`, `server/internal/quest/overrides/lua/converted-perl/trakanon/#Kaiaren.lua`
- Status: mad Kaiaren no longer grants the Celestial Fists final reward; the final hand-in belongs to true/sane Kaiaren.

P99 warns that giving the final Book of Celestial Fists and Demon Fangs hand-in to mad Kaiaren can destroy the items. IdleQuest's standard turn-in behavior returns unaccepted items rather than intentionally deleting high-value quest progress.

Decision for now: match the reward/NPC requirement but keep IdleQuest's safer item-return behavior for this wrong-NPC case.

### Messages For Neriak faction and EXP amounts

- P99 page: `https://wiki.project1999.com/Messages_For_Neriak`
- Local quest keys: `neriakc/Noxhil_V-Sek`, `commons/Kizdean_Gix`, `neriakc/Loveal_S-Nez`
- Local files: `server/internal/quest/overrides/lua/converted-perl/neriakc/Noxhil_V-Sek.lua`, `server/internal/quest/overrides/lua/converted-perl/commons/Kizdean_Gix.lua`, `server/internal/quest/overrides/lua/converted-perl/neriakc/Loveal_S-Nez.lua`
- Status: Noxhil's courier-duties prompt and Sealed List reward were added; Loveal's final Sealed Letter hand-in now includes the P99-documented faction directions and EXP.

P99 documents the final Loveal letter hand-in as granting faction and experience, but it does not provide exact numeric faction amounts or EXP. Local ProjectEQ-derived Lua previously gave only the bandages, iron rations, torch, and 4 copper.

Decision for now: use the same small The Dead courier-style faction block used by adjacent Noxhil work and grant conservative local EXP so the documented mechanics exist. Revisit only if a P99-confirmed exact amount source is found.

### Mining Caps Talrigar and skeleton variant gaps

- P99 page: `https://wiki.project1999.com/Mining_Caps`
- Local quest keys: `tox/abandoned_heretic_pet`, `tox/a_skeleton`, `toxxulia/abandoned_heretic_pet`, `toxxulia/a_skeleton`
- Local files: `server/internal/quest/overrides/lua/converted-perl/tox/abandoned_heretic_pet.lua`, `server/internal/quest/overrides/lua/converted-perl/tox/a_skeleton.lua`, `server/internal/quest/overrides/lua/converted-perl/toxxulia/abandoned_heretic_pet.lua`, `server/internal/quest/overrides/lua/converted-perl/toxxulia/a_skeleton.lua`
- Status: spawned abandoned heretic pet and mining skeleton cap turn-ins were restored for both Toxxulia zone aliases.

P99 documents a Talrigar Eklorin two-cap turn-in with Heretics-positive and Erudin-faction-negative hits, but local `npc_types`/spawn data does not contain Talrigar Eklorin. P99 does not provide enough path/spawn data to reconstruct him accurately in this batch.

P99 also distinguishes a left-hand skeleton gem reward and a right-hand skeleton undead-part reward. The old ProjectEQ `tox/38016.pl` only implements the right-hand skeleton, while the named `toxxulia/a_skeleton.pl` also only implements that right-hand behavior. Local spawn coordinates expose the likely miner pairs, so the new named Lua guards cap hand-ins to `tox` ids `38016/38017` and `toxxulia` ids `414103/414104`, with one left and one right behavior.

Decision for now: make the spawned pet/skeleton versions playable and prevent unrelated skeletons from eating caps. Leave Talrigar as a missing-NPC review item until a better spawn/path source is available.

### Rabid Wolves coin and EXP approximation

- P99 page: `https://wiki.project1999.com/Rabid_Wolves`
- Local quest key: `qeynos2/Priestess_Caulria`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/qeynos2/Priestess_Caulria.lua`
- Status: local now accepts the turn-in at dubious-or-better faction and grants Cure Disease, faction, EXP, and small coin.

P99 documents Diseased Wolf Pelt as granting small coin, experience, Cure Disease, and the Temple of Life faction directions. The page gives player-measured EXP examples but does not specify an exact coin amount.

Decision for now: use the page's level-10 Wood Elf Ranger EXP estimate as the static local EXP value and a fixed 1-silver small coin reward. Revisit only if an exact P99 coin table is found.

### Ranger Epic full-chain fidelity

- P99 page: `https://wiki.project1999.com/Ranger_Epic_Quest`
- Local quest keys: many Classic/Kunark chain NPCs from Telin Darkforest through Xanuusus
- Status: local Lua coverage exists; full chain not marked P99-complete.

The local repo has Lua for many Ranger Epic chain NPCs and the final Swiftwind/Earthcaller reward paths, but the P99 page is a large multi-zone chain with forage items, recipe combines, spawned combat, Venril Sathir remains flow, Plane of Sky drops, Plane of Hate drops, and several intermediate turn-ins.

Decision for now: keep the existing Ranger Epic chain enabled, but do not mark it fully P99-aligned until it receives a dedicated end-to-end chain audit.

### Ranger Plane of Sky starter flow

- P99 page: `https://wiki.project1999.com/Ranger_Plane_of_Sky_Tests`
- Local quest keys: `airplane/Ranger_Spirit`, `airplane/Relinin_Skyrunner`, `airplane/Gordon_Treecaller`
- Local files: `server/internal/quest/upstream/projecteq/airplane/Ranger_Spirit.lua`, `server/internal/quest/overrides/lua/modified-upstream/airplane/Relinin_Skyrunner.lua`, `server/internal/quest/upstream/projecteq/airplane/Gordon_Treecaller.lua`
- Status: Relinin and Gordon direct test hand-ins match the P99 item/reward sets after correcting the Body-test reward.

P99 documents a book handoff from Ranger Spirit before summoning the tester NPCs. Local Ranger Spirit directly spawns the selected tester from dialogue, matching the simplified Sky starter pattern already documented for other classes.

Decision for now: keep the direct tester-spawn flow and treat exact Plane of Sky book-handoff behavior as a review item unless Sky starter fidelity becomes gameplay-critical.

### Mirgon Dower's Head Skull of Torture item identity

- P99 page: `https://wiki.project1999.com/Mirgon_Dower%27s_Head`
- Local quest keys: `kurn/a_skeletal_cook`, `cabeast/Lord_Korzin`
- Local files: `server/internal/quest/overrides/lua/converted-perl/kurn/a_skeletal_cook.lua`, `server/internal/quest/overrides/lua/converted-perl/cabeast/Lord_Korzin.lua`
- Status: a skeletal cook now accepts and returns `Glowing Skull` item `12401`; the broken combine path remains unimplemented.

The P99 Mirgon page names the reward as `The Skull of Torture`, but its hand-in text says the cook places the skull back in the player's hands. The same page's ID notes list `12401` as `A glowing skull` with Skull of Torture lore and list `12400` only as an unknown likely reward item. The local Cabilis crusader chain already requires `Glowing Skull` item `12401` for Lord Korzin's later P99-documented step.

ProjectEQ's Perl script used item `59526` for The Skull of Torture, but IdleQuest's current item table does not contain item `59526`; local item `12401` does exist and already functions as the later crusader-chain turn-in.

Decision for now: use `12401` for the cook reward/hand-back so the P99 Mirgon step and Lord Korzin follow-up remain internally consistent. Do not add the broken recipe path that P99 explicitly says does not work.

### Key to Charasis exact EXP amount

- P99 page: `https://wiki.project1999.com/Key_to_Charasis_Quest`
- Local quest key: `swampofnohope/Dugroz`
- Local file: `server/internal/quest/overrides/lua/converted-perl/swampofnohope/Dugroz.lua`
- Status: Dugroz dialogue now follows the P99 key/small-favor flow and the final hand-in grants EXP.

P99 documents that the Xalgozian Fang + Jade Chokidai Prod hand-in grants experience, but does not provide an exact amount. The local script previously granted the key and zone flag but no EXP.

Decision for now: grant a conservative local `1000` EXP so the documented EXP mechanic exists, and revisit only if an exact P99 value is found.

### Knight Card Quest Blackened Iron Crown reward

- P99 page: `https://wiki.project1999.com/Knight_Card_Quest`
- Local quest key: `oot/Doran_Vargnus`
- Local file: `server/internal/quest/overrides/lua/converted-perl/oot/Doran_Vargnus.lua`
- Status: Doran's reward pool was expanded to the P99-listed reward items that exist locally; one listed item is missing.

P99's Knight Card Quest reward list includes `Blackened Iron Crown`. The cached P99 all-pages index has a `Blackened Iron Crown` title, but IdleQuest's `items` table does not contain an item by that name. Local does contain `Blackened Iron Coif`, but this audit did not substitute it because the P99 quest page names Crown explicitly.

Decision for now: omit `Blackened Iron Crown` from Doran's random reward pool, document it in `docs/quest-missing-items.md`, and keep the rest of the quest functional.

### Journal Strongbox ground-spawn z coordinate

- P99 page: `https://wiki.project1999.com/Journal_Strongbox`
- Local quest keys: `freportw/Nusk_Treton`, `freporte/Lenka_Stoutheart`
- Migration: `server/migrations/080_add_journal_strongbox_and_disable_rott_pages.sql`
- Status: Strongbox ground spawn added in Ocean of Tears at the P99 x/y location.

P99 documents the Strongbox location as `(-400, -9200)` straight out from the Sisters' docks in Ocean of Tears, but does not document a z coordinate. Local `ground_spawns` generally use `fix_z = 1`, so the migration uses `max_z = -99999` and `fix_z = 1` instead of inventing a hardcoded underwater z.

Decision for now: add the required ground spawn with P99 x/y and engine-resolved z; revisit only if in-game inspection shows the spawn is inaccessible or visibly misplaced.

### Keeper Rott's Pages disabled P99 drops

- P99 page: `https://wiki.project1999.com/Keeper_Rott%27s_Pages`
- Local quest key: `cabwest/Keeper_Rott`
- Local file: `server/internal/quest/overrides/lua/converted-perl/cabwest/Keeper_Rott.lua`
- Migration: `server/migrations/080_add_journal_strongbox_and_disable_rott_pages.sql`
- Status: goblin note-page drops removed; Keeper Rott Lua left enabled.

The P99 page says this quest was disabled as of November 12, 2025 because the note pages were not working correctly in the 1999 era, and that the pages no longer drop from goblins. Local had the note-page drops active on goblin spirit caller / goblin soothsayer lootdrops.

Decision for now: remove the normal note-page drops so the quest is unavailable in regular play, but keep Keeper Rott's dialogue script enabled because it also provides context for the necromancer skullcap chain. Do not add an in-game error message unless we later decide old/GM-created page items should also be rejected on turn-in.

### Illweed Parchment Quest confirmation and fishing rarity

- P99 page: `https://wiki.project1999.com/Illweed_Parchment_Quest`
- Local quest key: `cabeast/War_Historian_Kobl`
- Local file: `server/internal/quest/overrides/lua/converted-perl/cabeast/War_Historian_Kobl.lua`
- Migration: `server/migrations/078_add_lake_ill_omen_illweed_fishing.sql`
- Status: four-Illweed hand-in and Lake of Ill Omen fishing source added.

The P99 page is marked unsolved and says the information was taken from Allakhazam and is not presumed to be functional on P99. It nevertheless documents explicit dialogue, four Illweed reeds from fishing, and Illweed Parchment as the reward. Local already had the items and Kobl dialogue but no hand-in or fishing source.

Decision for now: implement the documented mechanic because it is Kunark-era and uses available local items. The fishing row uses a conservative 25 chance because P99 does not document a precise rarity.

### Incandescent Armor Silver Wand source NPC

- P99 page: `https://wiki.project1999.com/Incandescent_Armor_Quests`
- Local quest keys: `soltemple/Sultin`, `northkarana/Ezmirella`, `erudnext/Raine_Beteria`, `neriakc/Mizr_N-Mar`, `qeynos/Madame_Serena`, `highkeep/Tarn_Visilin`
- Local files: `server/internal/quest/overrides/lua/converted-perl/soltemple/Sultin.lua`, `server/internal/quest/upstream/projecteq/northkarana/Ezmirella.lua`, `server/internal/quest/upstream/projecteq/erudnext/Raine_Beteria.lua`, `server/internal/quest/overrides/lua/converted-perl/neriakc/Mizr_N-Mar.lua`, `server/internal/quest/overrides/lua/modified-upstream/qeynos/Madame_Serena.lua`, `server/internal/quest/upstream/projecteq/highkeep/Tarn_Visilin.lua`
- Migration: `server/migrations/079_align_incandescent_rune_sources.sql`
- Status: Rune of Fortune source locations aligned to P99; Sultin dialogue updated; Silver Wand source left for content review.

P99 says the Silver Wand drops from `a silvered guard` in Cazic Thule. Local has no `a_silvered_guard` NPC row; the Silver Wand currently drops from `a_silvered_Tae_Ew_observer` in Feerrott. Creating a new Cazic Thule NPC/spawn would require more source data than the P99 quest page provides.

Decision for now: do not invent a Cazic Thule silvered guard row in this batch. The Incandescent Wand remains completable locally through the existing Silver Wand source, but this source is not P99-accurate.

### Indaria's Doll coin reward

- P99 page: `https://wiki.project1999.com/Indaria%27s_Doll`
- Local quest key: `qeynos/Indaria`
- Local file: `server/internal/quest/upstream/projecteq/qeynos/Indaria.lua`
- Status: local Velvet Choker, faction, and EXP behavior kept.

P99 says Indaria gives experience, coin, and Velvet Choker, but does not document a coin amount. Local gives the Velvet Choker, faction, and EXP but no coin.

Decision for now: do not invent the missing coin amount.

### Innoruuk Recommendation / Symbol coin and exact faction amounts

- P99 pages: `https://wiki.project1999.com/Innoruuk_Recommendation`, `https://wiki.project1999.com/Innoruuk_Symbol_Quests`
- Local quest keys: `grobb/Savarixsa_Zexus`, `freporte/Saxarivza_Zaxun`, `freeporteast/Saxarivza_Zaxun`, `neriakc/Perrir_Zexus`, `neriakc/Ithvol_K-Jasn`, `neriakb/Draxiz_N-Ryt`, `neriaka/Dran_-slug-_Rembor`, `lfaydark/Dragoon_Szorn`, `steamfont/Ennixy_Frennor`
- Local files: `server/internal/quest/upstream/projecteq/grobb/Savarixsa_Zexus.lua`, `server/internal/quest/upstream/projecteq/freporte/Saxarivza_Zaxun.lua`, `server/internal/quest/overrides/lua/converted-perl/neriakc/Perrir_Zexus.lua`, `server/internal/quest/overrides/lua/converted-perl/neriakc/Ithvol_K-Jasn.lua`, `server/internal/quest/overrides/lua/converted-perl/neriakb/Draxiz_N-Ryt.lua`, `server/internal/quest/overrides/lua/converted-perl/neriaka/Dran_-slug-_Rembor.lua`, `server/internal/quest/overrides/lua/converted-perl/lfaydark/Dragoon_Szorn.lua`, `server/internal/quest/overrides/lua/converted-perl/steamfont/Ennixy_Frennor.lua`
- Status: Perrir's missing recommendation, skullcap, and Initiate Symbol branches restored; Dragoon Szorn's missing-shipment coin reward corrected to P99's 2-5pp range.

P99 documents minor coin for Leatherfoot Raider Skullcap and gives notes about large faction gains, but some exact amounts are uncertain/conflicting. Local now uses ProjectEQ-derived faction amounts and does not invent unspecified Perrir coin.

Decision for now: implement the mechanics and the clear Dragoon 2-5pp reward, but keep unspecified Perrir coin/faction variance documented.

### Hukulk's Love final coin reward

- P99 page: `https://wiki.project1999.com/Hukulk%27s_Love`
- Local quest keys: `grobb/Hukulk`, `innothule/Lynuga`, `neriaka/Guard_Lumpin`, `neriaka/Ratraz`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/grobb/Hukulk.lua`, `server/internal/quest/overrides/lua/modified-upstream/innothule/Lynuga.lua`, `server/internal/quest/overrides/lua/converted-perl/neriaka/Guard_Lumpin.lua`
- Migration: `server/migrations/076_add_guard_lumpin_troll_head_drop.sql`
- Status: Guard Lumpin's required Troll Head drop and Lynuga's Happy Love Bracers clue dialogue added; Hukulk final reward coin left unchanged.

The P99 page clearly documents Helm of Hukulk, faction, and experience. It also says the final reward includes "some money (even up to some plat!)" but does not document a stable amount or range.

Decision for now: make the quest mechanically completable with the documented required drops and dialogue, but do not invent the unspecified coin reward.

### Hungry Deputy coin randomness

- P99 page: `https://wiki.project1999.com/Hungry_Deputy`
- Local quest keys: `rivervale/Daleen_Leafsway`, `misty/Deputy_Eigon`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/rivervale/Daleen_Leafsway.lua`, `server/internal/quest/overrides/lua/converted-perl/misty/Deputy_Eigon.lua`
- Status: Daleen's timer blurt bug fixed; Deputy Eigon's existing fixed coin reward kept.

The P99 page says Deputy Eigon gives a random amount of coin ranging from a few copper to a couple gold, but it does not provide an exact table. Local currently gives one gold.

Decision for now: fix the clear dialogue/timer issue and leave the coin value stable until a more exact P99 coin table is available.

### Hurrieta's Tunic / Garuc Anehm coin amount

- P99 page: `https://wiki.project1999.com/Hurrieta%27s_Tunic_Quest`
- Local quest keys: `qeynos/Ton_Firepride`, `qcat/Garuc_Anehm`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/qeynos/Ton_Firepride.lua`, `server/internal/quest/overrides/lua/converted-perl/qcat/Garuc_Anehm.lua`
- Status: Ton Firepride's faction block corrected to the P99 factions; Garuc's item/faction/EXP reward kept, with no coin added.

The P99 page says Garuc gives "money" with the final Hurrieta's Bloody Dress reward, but does not document an amount. The ProjectEQ-derived Garuc script gives the documented item/faction/EXP reward but no coin.

Decision for now: correct the clear Ton faction mismatch, but do not invent Garuc coin.

### Iksar Prisoner Quest exact EXP/faction amounts

- P99 page: `https://wiki.project1999.com/Iksar_Prisoner_Quest`
- Local quest keys: `dalnir/an_Iksar_prisoner`, `cabeast/Arch_Duke_Xog`
- Local files: `server/internal/quest/overrides/lua/idlequest-authored/dalnir/an_Iksar_prisoner.lua`, `server/internal/quest/overrides/lua/converted-perl/cabeast/Arch_Duke_Xog.lua`
- Status: prisoner Serrated Wire hand-in and Arch Duke Xog Greenmist Icon bad-ending hand-in added.

The P99 page clearly documents the dialogue flow, Serrated Wire hand-in, Greenmist Icon reward, and negative Crusaders of Greenmist / Legion of Cabilis faction result. It does not document exact experience or negative faction amounts.

Decision for now: implement the documented mechanics with conservative local amounts so the quest exists and is testable; revisit if exact P99 amounts are found.

### Illegible Cantrip / Illegible Scroll reward pools

- P99 pages: `https://wiki.project1999.com/Illegible_Cantrip_Quest`, `https://wiki.project1999.com/Illegible_Scrolls`
- Local quest keys: `freportw/Tara_Neklene`, `freeportwest/Tara_Neklene`, `highkeep/Lozani`, `freporte/Lozani`, `freeporteast/Lozani`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/freportw/Tara_Neklene.lua`, `server/internal/quest/overrides/lua/modified-upstream/freeportwest/Tara_Neklene.lua`, `server/internal/quest/overrides/lua/modified-upstream/highkeep/Lozani.lua`, `server/internal/quest/overrides/lua/modified-upstream/freporte/Lozani.lua`, `server/internal/quest/overrides/lua/modified-upstream/freeporteast/Lozani.lua`
- Status: Tara now gives a minor item for cantrips and implements the kindly-or-better oracle scroll branch; East Freeport Lozani now has the same turn-in behavior as High Keep.

The P99 Tara page gives conflicting coin examples for cantrip turn-ins and does not provide an exact random table. The P99 Lozani page lists example low-level spell rewards, but does not prove the complete reward pool.

Decision for now: add the clear missing mechanics and documented example rewards, but keep the uncertain coin/reward-pool details explicit for later review.

### Honeybugger Assassin reward/start dialogue

- P99 page: `https://wiki.project1999.com/Honeybugger_Assassin`
- Local quest keys: `neriakc/Pazin_Punox`, `misty/Lil_Honeybugger`, `misty/Joogl_Honeybugger`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/neriakc/Pazin_Punox.lua`, `server/internal/quest/overrides/lua/converted-perl/misty/Lil_Honeybugger.lua`, `server/internal/quest/overrides/lua/converted-perl/misty/Joogl_Honeybugger.lua`
- Migration: `server/migrations/075_add_lil_honeybugger_drops.sql`
- Status: Lil Honeybugger drops and Pazin's Halfling Head hand-in added; no invented reward item added.

The P99 page says Pazin promises a "king's reward" and then betrays the player by giving "garbage from other guild exploits," but the reward box says `None?` and no exact start dialogue, reward item, faction hit, coin, or EXP is documented.

Decision for now: make the quest completable by adding Lil's documented drops and Pazin's documented betrayal response for the Halfling Head hand-in, but do not invent a reward item or exact start-dialogue branch.

### Head of Granin O'Gill spell reward

- P99 page: `https://wiki.project1999.com/Head_of_Granin_O%27Gill`
- Local quest key: `halas/Margyn_McCann`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/halas/Margyn_McCann.lua`
- Status: local coin reward updated to the P99 4 gold; spell reward pool kept.

The P99 page's reward box names `Spell: Spirit of Bear`, but the walkthrough also says the player receives one random shaman spell scroll. Local ProjectEQ-derived behavior grants one random low-level shaman spell scroll, including Spirit of Bear.

Decision for now: keep the random shaman spell pool and only correct the clear coin mismatch.

### Halfling Raider Helms faction amounts

- P99 page: `https://wiki.project1999.com/Halfling_Raider_Helms`
- Local quest key: `neriakb/Narex_T-Vem`
- Local file: `server/internal/quest/overrides/lua/converted-perl/neriakb/Narex_T-Vem.lua`
- Status: indifferent-or-better faction gate added; local faction amounts kept.

The P99 page says indifferent faction is required for the hand-in, but also notes that its faction hit amounts are from Allakhazam and may not match P99. Local now enforces the faction gate, but keeps the ProjectEQ-derived faction amounts for Indigo Brotherhood, Emerald Warriors, Steel Warriors, and Primordial Malice.

Decision for now: keep the local faction amounts until a P99-confirmed value source is found.

### Wolves of the North faction block

- P99 page: `https://wiki.project1999.com/Guild_Summons_-_Wolves_of_the_North`
- Local quest keys: `halas/Kylan_O-Danos`, `halas/Kylan_O\`Danos`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/halas/Kylan_O-Danos.lua`, `server/internal/quest/overrides/lua/modified-upstream/halas/Kylan_O_Danos_alias.lua`
- Status: starting-note reward and text updated to P99; local faction path kept.

The P99 page for the Halas warrior starter note documents the Patched Fur Tunic reward and Kylan's success text, but its faction block does not list Wolves of the North and instead says Rogues of the White Rose and Shadowed Men improve. That contradicts the guild context and local ProjectEQ-derived behavior, which improves Wolves of the North, Shamen of Justice, Merchants of Halas, and Steel Warriors.

Decision for now: keep the local Wolves of the North faction path, update the text to P99, and revisit only if another classic/P99 source confirms the unusual faction block.

### Caskin Marsheart soulbinder/Geadin dialogue

- P99 page: `https://wiki.project1999.com/Guild_Summons_-_Marsheart%27s_Chords`
- Local quest keys: `freportn/Caskin_Marsheart`, `freeporteast/Caskin_Marsheart`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/freportn/Caskin_Marsheart.lua`, `server/internal/quest/overrides/lua/modified-upstream/freeporteast/Caskin_Marsheart.lua`
- Status: starting-note behavior updated to P99; later soulbinder/Geadin dialogue removed from enabled local Lua pending review.

The local ProjectEQ-derived Caskin scripts contained a `druid_epic` global-gated dialogue branch about Soulbinder Grunson, Geadin, soulbinder problems, research, and madness. The scraped P99 quest-page corpus only documents Caskin for Marsheart's Chords and does not surface that branch as a P99/classic quest page.

Decision for now: keep Caskin's P99 Guild Summons hand-in enabled and remove the later soulbinder/Geadin branch from visible IdleQuest Lua. Revisit if another P99/classic source shows that dialogue belongs in the supported era.

### Dismal Rage Necromancer duplicate Opal faction

- P99 page: `https://wiki.project1999.com/Guild_Summons_-_Dismal_Rage_Necromancer`
- Local quest keys: `freporte/Opal_Darkbriar`, `freeporteast/Opal_Darkbriar`
- Local files: `server/internal/quest/upstream/projecteq/freporte/Opal_Darkbriar.lua`, `server/internal/quest/overrides/lua/modified-upstream/freeporteast/Opal_Darkbriar.lua`
- Status: local faction distribution kept; post-era trades prompt removed from the East Freeport alias.

P99 lists Opal Dark Briar faction improving twice on the Opal Darkbriar starting-note hand-in. Local ProjectEQ-derived behavior has Opal Dark Briar up, Dismal Rage up, The Dead up, Dark Reflection up, and Bloodsabers up. The duplicate Opal line on P99 could be an actual duplicate faction hit, a page/log artifact, or a mislabeled Dark Reflection line.

Decision for now: keep local Dark Reflection faction until another source confirms whether P99 really applies Opal twice.

### Faydark's Champions trades prompt

- P99 page: `https://wiki.project1999.com/Guild_Summons_-_Faydark%27s_Champions`
- Local quest key: `gfaydark/Maesyn_Trueshot`
- Local file: `server/internal/quest/overrides/lua/converted-perl/gfaydark/Maesyn_Trueshot.lua`
- Status: starting note remains functional; literal `$name` conversion bug fixed.

The P99 Guild Summons page for Maesyn includes a later-style sentence about progressing through ranks and learning various `[trades]`, but the page does not document any trade-book reward path and IdleQuest does not currently have the later `Tradeskill Basics` books in the Classic/Kunark item set.

Decision for now: keep Maesyn's local starting-note response free of the unsupported trades prompt, but keep the P99 item/faction/reward behavior.

### Welno Tanboots vs Welno Tanlonikan

- P99 page: `https://wiki.project1999.com/Guild_Summons_-_Abbey_of_Deep_Musing_Rogue`
- Local quest key: `akanon/Welno_Tanlonikan`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/akanon/Welno_Tanlonikan.lua`
- Status: starting-note hand-in works locally under the local NPC name; no NPC rename made.

P99 names the Abbey of Deep Musing rogue guildmaster `Welno Tanboots`. The local EQEmu-derived NPC/item data uses `Welno Tanlonikan`, including the starting-note item lore, and the local spawn coordinates match the P99 guild location closely enough for the quest to be functional.

Decision for now: keep the local NPC/script key as `Welno_Tanlonikan` and only align the starting-note text/reward behavior. Revisit if we decide to rename DB NPCs for exact P99 presentation.

### Crimson Hands Guild Summons faction block

- P99 page: `https://wiki.project1999.com/Guild_Summons_-_Crimson_Hands`
- Local quest key: `erudnint/Ghanlin_Skyphire`
- Local file: `server/internal/quest/upstream/projecteq/erudnint/Ghanlin_Skyphire.lua`
- Status: local script unchanged.

The P99 page is for Ghanlin Skyphire, Master Wizard of the Crimson Hands, but its faction block says `Craftkeepers` improves. Local Lua rewards `Crimson Hands`, which matches the page title, NPC dialogue, and guild context.

Decision for now: keep the local Crimson Hands faction reward and treat the P99 faction block as likely copy/paste drift unless another source confirms Craftkeepers is correct.

### Gearheart random reward pool

- P99 page: `https://wiki.project1999.com/Gearheart_(Quest)`
- Local quest key: `akanon/Baxok_Curhunter`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/akanon/Baxok_Curhunter.lua`
- Status: P99 cash/EXP/success text fixed; random reward pool left as ProjectEQ-derived low-level item pool.

P99's reward box lists `Small Leather Wristbands`, but the walkthrough says the player receives "a random low-level item." Local ProjectEQ-derived Lua already used a random cloth/shield pool. This batch added the documented 4 silver and EXP but did not collapse the reward pool to only Small Leather Wristbands.

Decision for now: keep the random low-level item pool until another source confirms whether P99's reward box is a single observed reward or the complete reward table.

### Geozite Tool exact EXP amounts

- P99 page: `https://wiki.project1999.com/Geozite_Tool_Quest`
- Local quest keys: `cabeast/Drill_Master_Vygan`, `swampofnohope/Warlord_Hikyg`, `fieldofbone/Warlord_Zyzz`, `warslikswood/Warlord_Vyzer`
- Local files: `server/internal/quest/overrides/lua/converted-perl/cabeast/Drill_Master_Vygan.lua`, `server/internal/quest/overrides/lua/converted-perl/swampofnohope/Warlord_Hikyg.lua`, `server/internal/quest/overrides/lua/converted-perl/fieldofbone/Warlord_Zyzz.lua`, `server/internal/quest/overrides/lua/converted-perl/warslikswood/Warlord_Vyzer.lua`
- Migration: `server/migrations/073_enable_p99_classic_quest_combines.sql`
- Status: item/cash/faction/combine mechanics updated; exact EXP amounts need confirmation.

P99 documents EXP for the Drill Master Vygan and Warlord Hikyg/Zyzz/Vyzer Geozite hand-ins, but does not give exact EXP amounts. Local now uses conservative ProjectEQ-style EXP values and restores/creates the required container combines.

Decision for now: keep the quest functional with documented items/cash/factions, and revisit exact EXP values only if a better P99/source value is found.

### Bone Chips Felwithe reward list

- P99 page: `https://wiki.project1999.com/Bone_Chips_Felwithe`
- Local quest key: `felwithea/Yeolarn_Bronzeleaf`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/felwithea/Yeolarn_Bronzeleaf.lua`
- Status: local turn-in matches the P99 walkthrough; no Lua change made for the extra reward-box item.

The P99 reward box lists both `Spell: Strike` and `Fine Steel Short Sword`, but the walkthrough success text says Yeolarn rewards the player with "this spell" and does not mention a sword. Local ProjectEQ-derived Lua grants only `Spell: Strike` plus the documented faction/experience.

Decision for now: keep the local reward as `Spell: Strike` only until another source confirms whether the Fine Steel Short Sword is a true reward or a P99 page/template artifact.

### Bracers of Erollisi coin reward

- P99 page: `https://wiki.project1999.com/Bracers_of_Erollisi_Quest`
- Local quest key: `oot/Styria_Fearnon`
- Local file: `server/internal/quest/upstream/projecteq/oot/Styria_Fearnon.lua`
- Status: item reward/faction/EXP match; local also grants coin not documented by P99; no Lua change made.

The P99 page documents the Bracers of Erollisi turn-in reward as one random item from Aviak Feather, Conch Shell, Fishing Spear, or Kiola Nut, plus faction and experience. Local ProjectEQ Lua also grants 5 gold and 5 silver. The P99 page does not explicitly say no coin is awarded.

Decision for now: leave the local coin reward unchanged until another source confirms whether P99 omits or excludes coin here.

### Bozinite Pestle Cleaner VII spawn/drop rates

- P99 page: `https://wiki.project1999.com/Bozinite_Pestle_Quest`
- Local quest keys: `akanon/Larkon_Theardor`, `kaladimb/Myre`, `kaladimb/Cleaner_VII`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/akanon/Larkon_Theardor.lua`, `server/internal/quest/overrides/lua/converted-perl/kaladimb/Myre.lua`, `server/internal/quest/overrides/lua/converted-perl/kaladimb/Cleaner_VII.lua`
- Status: Larkon turn-in corrected; Cleaner VII exists and drops Bozinite Pestle locally; exact spawn/drop rates not changed.

P99 says Cleaner VII has several rat placeholders, about a 10% chance to spawn, and does not always drop the Bozinite Pestle. Local DB has Cleaner VII spawned in North Kaladim and its loot table includes Bozinite Pestle at about 16.5%. Exact placeholder/spawn/drop tuning is a spawn/loot audit question rather than a Lua turn-in mismatch.

Decision for now: keep the local spawn/drop data unchanged in this quest-page batch and revisit during a dedicated spawn/loot accuracy pass if needed.

### Beta Neutral

- P99 page: `https://wiki.project1999.com/Beta_Neutral`
- Local quest key: `neriakc/Mizr_N-Mar`
- Local file: `server/internal/quest/overrides/lua/converted-perl/neriakc/Mizr_N-Mar.lua`
- Status: local script gives Rune of Fortune for 50 gold / 5 platinum, but does not award Beta Neutral faction; no Lua change made for faction amount.

The P99 page says buying/turning in for the Rune of Fortune boosts Beta Neutral faction, but it does not document the amount. The local ProjectEQ-derived script summons the Rune of Fortune and leaves faction unchanged.

Decision for now: keep the local item reward working, and do not add a guessed Beta Neutral faction value until the correct amount is sourced.

### Blessed Oil final spell pool

- P99 pages: `https://wiki.project1999.com/Blessed_Oil`, `https://wiki.project1999.com/Blessed_Oil_Quest`
- Local quest keys: `qey2hh1/Brother_Estle`, `qeynos2/Nomsoe_Jusagta`, `qeynos2/Priestess_Jahnda`, `southkarana/#Brother_Hayle`, `qeynos2/Tyokan_Mekase`
- Local files: `server/internal/quest/upstream/projecteq/qey2hh1/Brother_Estle.lua`, `server/internal/quest/upstream/projecteq/qeynos2/Nomsoe_Jusagta.lua`, `server/internal/quest/overrides/lua/modified-upstream/qeynos2/Priestess_Jahnda.lua`, `server/internal/quest/overrides/lua/modified-upstream/southkarana/#Brother_Hayle.lua`, `server/internal/quest/upstream/projecteq/qeynos2/Tyokan_Mekase.lua`
- Status: missing PrayerBeads -> Temple Summons hand-in fixed; Brother Hayle Bloodsabers faction sign fixed; final Tyokan spell pool left unchanged pending review.

The two scraped P99 pages conflict on the final strongbox reward. `Blessed Oil` lists `Spell: Greater Healing`, `Spell: Inspire Fear`, and `Spell: Ward Summoned`; `Blessed Oil Quest` lists only `Spell: Inspire Fear` and `Spell: Ward Summoned`. Local Tyokan currently uses the two-spell pool, with Inspire Fear weighted twice.

Decision for now: leave Tyokan's final spell pool unchanged until another source or live P99 behavior confirms whether Greater Healing belongs in the current P99 reward pool.

### Blood Ink

- P99 page: `https://wiki.project1999.com/Blood_Ink`
- Local quest key: `cabeast/War_Historian_Kobl`
- Local file: `server/internal/quest/overrides/lua/converted-perl/cabeast/War_Historian_Kobl.lua`
- Status: P99 page is unsolved/incomplete; local script is dialogue-only; no Lua change made.

P99 says it is unknown whether the quest is implemented and asks for dialogue, faction, quest mobs, quest items, and rewards. The local ProjectEQ-derived script only has War Historian Kobl's dialogue for blood ink and illweed parchment.

Decision for now: keep the dialogue enabled, but do not invent turn-ins or rewards.

### Acumen Mask Quest

- P99 page: `https://wiki.project1999.com/Acumen_Mask_Quest`
- Local quest key: `soltemple/Vilissia`
- Local file: `server/internal/quest/overrides/lua/converted-perl/soltemple/Vilissia.lua`
- Status: item/faction/reward item match; EXP behavior needs review; no Lua change made for this point.

The local Vilissia script uses a shared `temple_faction` helper for Acumen Mask, Runescale Cloak, Lambent Ruby, and Vulcanized Platinum Bar. That helper grants 1000 EXP. P99's Acumen Mask page documents Temple of Solusek Ro faction up and Shadowed Men faction down, but does not document EXP. Related Vilissia pages, such as Runescale Cloak, do document EXP, so changing the shared helper during the Acumen audit could accidentally alter other quests.

Decision for now: leave Vilissia EXP behavior unchanged until the related Vilissia/Temple Sol Ro quest pages are audited together.

### Bat Fur Quest

- P99 page: `https://wiki.project1999.com/Bat_Fur_Quest`
- Local quest key: `qeynos/Caleah_Herblender`
- Local file: `server/internal/quest/upstream/projecteq/qeynos/Caleah_Herblender.lua`
- Status: ambiguous; no Lua change made.

The P99 page is internally inconsistent. It describes Caleah asking for three distinct ingredients: `Rat Whiskers` item `13071`, `Fire Beetle Eye` item `10307`, and `Bat Fur` item `13069`, but also includes a note claiming a specific turn-in order with two Bat Fur. The local Lua currently implements the three-distinct-item version and the documented reward/faction/cash path.

Decision for now: leave local behavior unchanged until this can be confirmed against another classic source or live P99 behavior.

### Bard Reports / Quinon Hulleaf

- P99 page: `https://wiki.project1999.com/Bard_Reports`
- Local quest keys: `qeynos/Jusean_Evanesque`, `qeynos2/Quinon_Hulleaf`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/qeynos/Jusean_Evanesque.lua`, `server/internal/quest/upstream/projecteq/qeynos2/Quinon_Hulleaf.lua`
- Status: known Jusean/Anehan/Behroe/Leanon paths match; Quinon path is locally implemented but P99 page is incomplete.

The P99 Bard Reports page explicitly says Quinon dialogue, faction hits, and quest items are still needed. Local ProjectEQ Lua implements Quinon as a North Gate report path parallel to Leanon. This is plausible and keeps the local quest functional, but it is not directly confirmed by the P99 page.

Decision for now: keep the local Quinon path enabled and mark it as P99-incomplete for later review.

### Barnacle Breastplate Quest shark spawn path

- P99 page: `https://wiki.project1999.com/Barnacle_Breastplate_Quest`
- Local quest key: `erudnext/Weligon_Steelherder`
- Local file: `server/internal/quest/upstream/projecteq/erudnext/Weligon_Steelherder.lua`
- Migration: `server/migrations/073_enable_p99_classic_quest_combines.sql`
- Status: Weligon hand-in and container combine corrected; exact P99 shark spawn path needs later review.

P99 says `a diseased shark` drops the lore Heretic Shark Skin and spawns young sharks on death. The local Erudin data has shark mobs and loot rows for Heretic Shark Skin and Baby Shark Remains, but does not appear to have the exact named `a diseased shark` spawn/death-spawn behavior.

Decision for now: enable the P99 item/combine/turn-in path and leave exact low-level shark spawn behavior for a separate spawn/loot audit.

### Bearskin Gloves Quest

- P99 page: `https://wiki.project1999.com/Bearskin_Gloves_Quest`
- Local quest key: `kithicor/Ged_Twigborn`
- Local file: `server/internal/quest/overrides/lua/converted-perl/kithicor/Ged_Twigborn.lua`
- Status: known hand-in/reward match; P99 page lacks dialogue and faction details.

The P99 page only documents the 25 gold plus High Quality Bear Skin hand-in for Bearskin Gloves and says missing dialogues/faction hits are needed. Local converted ProjectEQ Lua implements that hand-in and also includes dialogue plus additional lion/rat/wolf glove recipes.

Decision for now: keep the local ProjectEQ dialogue/extra glove hand-ins, because they do not contradict the P99 page, but mark the page as incomplete rather than fully confirmed.

### Blackburrow Stout Shipment / Gnasher EXP

- P99 page: `https://wiki.project1999.com/Blackburrow_Stout_Shipment`
- Local quest keys: `qeynos/McNeal_Jocub`, `qeytoqrg/Gnasher_Furgutt`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/qeynos/McNeal_Jocub.lua`, `server/internal/quest/upstream/projecteq/qeytoqrg/Gnasher_Furgutt.lua`
- Status: final McNeal return corrected; intermediate Gnasher EXP/Ding left unchanged pending review.

The P99 page has `{{exp}}` after the Gnasher hand-in, but also includes a later note saying a level 5 druid received no experience and no traditional quest ding from that portion on Green on December 12, 2023. Local ProjectEQ currently grants EXP and Ding for Gnasher's intermediate note hand-in.

Decision for now: leave local Gnasher EXP/Ding unchanged because the P99 page contradicts itself, and only correct the clearly documented final McNeal coin/EXP reward.

### Burnished Wooden Staff Quest EXP

- P99 page: `https://wiki.project1999.com/Burnished_Wooden_Staff_Quest`
- Local quest key: `warslikswood/Ssolet_Dnaas`
- Local file: `server/internal/quest/overrides/lua/converted-perl/warslikswood/Ssolet_Dnaas.lua`
- Status: item reward/dialogue match; local EXP left unchanged pending review.

The P99 page documents the `Burnished Wooden Stave` hand-in reward as `Piece of a medallion` with lore `Top shard of the Obulus Medallion`. Local converted ProjectEQ Lua gives the correct item ID `19958` and also grants 1000 EXP. The P99 page does not explicitly say no EXP is awarded; it simply omits an EXP marker.

Decision for now: keep the local EXP reward until another source confirms whether P99 omits or excludes EXP for this VP-key shard turn-in.

### Caduceus of Sacrament faction/EXP

- P99 page: `https://wiki.project1999.com/Caduceus_of_Sacrament_Quest`
- Local quest keys: `soltemple/Gavel_the_Temperant`, `soltemple/Ostorm`
- Local files: `server/internal/quest/upstream/projecteq/soltemple/Gavel_the_Temperant.lua`, `server/internal/quest/upstream/projecteq/soltemple/Ostorm.lua`
- Status: local item path/reward matches; exact faction/EXP left unchanged pending review.

The P99 page documents the required items and `Caduceus of Sacrament` reward, but its faction block explicitly says current faction hits are needed and it does not document exact EXP. Local ProjectEQ-derived Lua uses the shared Temple Solusek Ro helper, which grants Temple of Solusek Ro faction up, Shadowed Men faction down, and EXP.

Decision for now: keep the local shared Temple Sol Ro helper behavior until Temple Sol Ro faction/EXP values are audited as a group.

### Catfish Tail reward conflict

- P99 page: `https://wiki.project1999.com/Catfish_Tail`
- Local quest key: `erudnext/Vynon_Estaliun`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/erudnext/Vynon_Estaliun.lua`
- Status: local script updated conservatively; reward conflict still needs review.

The P99 reward box lists `Brass Ring` and `Torch`, while the walkthrough text says Vynon gives 5 copper and does not mention either item. The local ProjectEQ-derived script already granted `Brass Ring`.

Decision for now: keep `Brass Ring`, add the walkthrough-documented 5 copper, and do not add `Torch` until another source confirms it is a real P99 reward rather than a page/template artifact.

### Cleanse the Ocean swimmer drop/faction distribution

- P99 page: `https://wiki.project1999.com/Cleanse_the_Ocean`
- Local quest key: `erudnext/Laoni_Reista`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/erudnext/Laoni_Reista.lua`
- Status: Laoni reward/faction/EXP path corrected; exact swimmer loot/faction behavior needs spawn/loot review.

P99 says the Erudin Bay swimmers, except Buzzlin Bornahm, can drop `A Nicked Coin` and documents Qeynos rogue/guard faction changes on at least Lenya Wisk death. The local DB currently has obtainable `Nicked Coin` drops on Grendin Maze, Megan Tiglin, and Taler Bilge, but not every P99-listed swimmer has the coin in local loot data.

Decision for now: keep the quest functional and P99-correct at the Laoni turn-in layer. Defer exact swimmer loot distribution and death-faction behavior to a dedicated spawn/loot/faction audit.

### Clurg's Revenge faction detail

- P99 page: `https://wiki.project1999.com/Clurg's_Revenge`
- Local quest keys: `oggok/Clurg`, `neriaka/Pungla`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/oggok/Clurg.lua`
- Status: reward pool corrected; faction amounts left unchanged.

P99 lists the reward pool as `Crude Stein`, `Ogre War Maul`, `Pearl`, or `Warhammer`, and says detailed faction hits are still needed. Local ProjectEQ-derived Clurg also included Large Ringmail rewards, which were removed. Local faction hits remain ProjectEQ-derived because the P99 page does not document exact turn-in faction amounts.

Decision for now: use the P99 reward pool and leave local faction amounts unchanged until a better faction source is found.

### Corrupt Guards (Cleric version) random spell pool

- P99 page: `https://wiki.project1999.com/Corrupt_Guards_(Cleric_version)`
- Local quest key: `freportn/Jemoz_Lerkarson`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/freportn/Jemoz_Lerkarson.lua`
- Status: P99 success text and Minor Healing cast added; exact random scroll pool needs review.

The P99 page documents the `Damaged Militia Helm` reward as a random cleric spell scroll plus a Minor Healing cast, but it does not list the exact scroll pool. Local IdleQuest now casts Minor Healing and uses the existing ProjectEQ Jemoz cleric-scroll pool: `Spell: Furor`, `Spell: Root`, `Spell: Center`, `Spell: Fear`, `Spell: Invigor`, and `Spell: Healing`.

Decision for now: keep the local ProjectEQ cleric-scroll pool so the quest gives a spell reward, but revisit if a P99-specific item pool is sourced.

### Cromil's Remains reward conflict

- P99 page: `https://wiki.project1999.com/Cromil's_Remains`
- Local quest key: `kaladimb/Gunlok_Jure`
- Local file: `server/internal/quest/overrides/lua/converted-perl/kaladimb/Gunlok_Jure.lua`
- Status: faction gate restored; reward item not changed.

The P99 page conflicts with itself: the reward box lists `Spell: Hammer of Wrath`, while the walkthrough says the player received `Spell: Spook the Dead`. The ProjectEQ source script rewards `Spell: Flash of Light`.

Decision for now: restore the clear amiable-or-better faction gate from the ProjectEQ/P99 text, but keep the existing `Spell: Flash of Light` reward until another source confirms the actual P99 reward.

### Cursed Wafers copper amount

- P99 page: `https://wiki.project1999.com/Cursed_Wafers_Quest`
- Local quest key: `cabeast/Hierophant_Oxyn`
- Local file: `server/internal/quest/upstream/projecteq/cabeast/Hierophant_Oxyn.lua`
- Migration: `server/migrations/073_enable_p99_classic_quest_combines.sql`
- Status: recipe enabled; item/faction/EXP path kept; exact copper not changed.

P99's walkthrough text says Hierophant Oxyn gives "a few copper" with the two Cursed Wafers, but the reward box does not list coin and the page does not provide an exact amount. Local ProjectEQ-derived Lua gives the two wafers plus faction/EXP and no coin.

Decision for now: enable the required `Full Component Mortar` combine and leave the copper reward unchanged until another source confirms the exact amount.

### Deathfist Slashed Belts exact coin/faction values

- P99 page: `https://wiki.project1999.com/Deathfist_Slashed_Belts`
- Local quest keys: `freportw/Cain_Darkmoore`, `freportw/Captain_Hazran`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/freportw/Cain_Darkmoore.lua`, `server/internal/quest/overrides/lua/modified-upstream/freportw/Captain_Hazran.lua`
- Status: clear behavior corrected; exact faction amounts and Cain random coin behavior need review.

P99 documents Cain's good-side reward as 2-10 gold and shows a 6 gold example. Local IdleQuest uses the existing fixed 8 gold value, which is inside that range. P99 also documents faction directions but not exact numeric faction deltas. Hazran's evil-side page documents 3 gold per belt and supports 1-4 belts per turn-in; local now follows that item/coin shape and scales the existing ProjectEQ faction/EXP values per belt.

Decision for now: keep Cain's fixed in-range 8 gold and ProjectEQ-derived faction magnitudes, but revisit if exact P99 coin distribution or faction values are sourced.

### Crusader's Tests full-chain fidelity

- P99 page: `https://wiki.project1999.com/Crusader's_Tests`
- Local quest keys: `cabeast/Arch_Duke_Xog`, `cabeast/Lord_Gikzic`, `cabeast/Lord_Korzin`, `cabeast/Lord_Qyzar`, `firiona/Tracker_Azeal`, `firiona/Hero_Goxnok`
- Local files: `server/internal/quest/overrides/lua/converted-perl/cabeast/Arch_Duke_Xog.lua`, `server/internal/quest/overrides/lua/converted-perl/cabeast/Lord_Gikzic.lua`, `server/internal/quest/overrides/lua/converted-perl/cabeast/Lord_Korzin.lua`, `server/internal/quest/overrides/lua/converted-perl/cabeast/Lord_Qyzar.lua`, `server/internal/quest/overrides/lua/converted-perl/firiona/Tracker_Azeal.lua`, `server/internal/quest/overrides/lua/converted-perl/firiona/Hero_Goxnok.lua`
- Status: not marked fully matching.

The early Khukri NPC turn-ins are implemented locally and match the P99 item progression at a high level. The full page, however, includes recipe combines, ground spawns, timed NPC state, temporary/spawned NPCs, movement, combat drops, and the Chardok-revamp Greenmist continuation.

Decision for now: keep the existing quest chain enabled, but do not mark the entire Crusader's Tests chain P99-complete until it receives a dedicated end-to-end chain audit.

### Di'Zok Signet of Service Chardok Revamp scope

- P99 page: `https://wiki.project1999.com/Di'Zok_Signet_of_Service_Quest`
- Local quest key: `chardok/Herald_Telcha`
- Local file: `server/internal/quest/overrides/lua/converted-perl/chardok/Herald_Telcha.lua`
- Status: clear level/faction bug fixed; era-scope decision needs review.

P99 marks this quest as Chardok Revamp Era, but the quest is based in Chardok/Droga and all involved item rows exist locally. The local script previously granted `Di'zok Signet of Service` from keyword text alone. It now requires level 51+ and warmly-or-better Herald faction and uses the P99 failure dialogue buckets.

Decision for now: keep the quest enabled because it is Kunark-zone content and the user prefers including plausible era-borderline content unless it clearly involves Velious/later zones. Revisit if IdleQuest decides to exclude all Chardok Revamp content categorically.

### Dragon Scales Quest Sir Hobble spawn path

- P99 page: `https://wiki.project1999.com/Dragon_Scales_Quest`
- Local quest keys: `firiona/Lenka_Stoutheart`, `firiona/Bronto_Thudfoot`, `firiona/Sir_Hobble`, `firiona/Squire_Fuzzmin`, `overthere/Tektite`, `soltemple/Lord_Lyfyx_of_Burwood`
- Local files: `server/internal/quest/overrides/lua/converted-perl/firiona/Lenka_Stoutheart.lua`, `server/internal/quest/overrides/lua/converted-perl/firiona/Bronto_Thudfoot.lua`, `server/internal/quest/overrides/lua/converted-perl/firiona/Sir_Hobble.lua`, `server/internal/quest/overrides/lua/converted-perl/firiona/Squire_Fuzzmin.lua`, `server/internal/quest/overrides/lua/converted-perl/overthere/Tektite.lua`, `server/internal/quest/overrides/lua/converted-perl/soltemple/Lord_Lyfyx_of_Burwood.lua`
- Status: clear Lord Lyfyx turn-in fixed; P99 Lenka/Bronto/Sir Hobble trigger path needs a spawn-path audit.

The final Wurmslayer turn-in is implemented, Tektite can produce the Tektite item, and Lord Lyfyx now requires the P99 one Peridot plus Tektite instead of two Peridots plus Tektite. The local DB also has static Sir Hobble spawns, and hailing Sir Hobble can spawn Squire Fuzzmin.

P99's setup path, however, uses Lenka Stoutheart and Bronto Thudfoot dialogue to spawn Sir Hobble. Local Lenka/Bronto scripts are currently dialogue-only and do not implement that full trigger.

Decision for now: keep the quest functional at the turn-in layer and record the missing Lenka/Bronto spawn trigger for a dedicated spawn-path fix.

### Drolvarg Teeth Elven Trail Mix quantity

- P99 page: `https://wiki.project1999.com/Drolvarg_Teeth`
- Local quest key: `firiona/Captain_Nealith`
- Local file: `server/internal/quest/overrides/lua/converted-perl/firiona/Captain_Nealith.lua`
- Status: P99 cash/faction corrected; exact trail mix quantity needs review.

P99 documents the reward as `Elven Trail Mix`, 2-9 gold, 6-9 silver, 13 copper, faction, and experience. Local ProjectEQ-derived Lua summons `Elven Trail Mix` with quantity/charges `7`. The P99 page does not specify whether the reward is one trail mix or a stack/charge quantity.

Decision for now: correct the clearly documented coin and missing Emerald Warriors faction, but keep the inherited trail-mix quantity until another source confirms whether it should be one or seven.

### Drosco the Zombie local spawn identity and medal drop chance

- P99 page: `https://wiki.project1999.com/Drosco_the_Zombie_(good)`
- Local quest keys: `qeynos/Wolten_Grafe`, `qcat/#a_zombie`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/qeynos/Wolten_Grafe.lua`, `server/migrations/074_add_drosco_medal_drop.sql`
- Status: missing Wolten hand-in fixed and medal made obtainable; exact Drosco spawn identity/chance needs review.

P99 says Drosco occasionally drops `A Sealed Letter` and more rarely drops Drosco's `Order of Thunder`, which Wolten exchanges for `Thunder Staff`. Local data has no `Drosco`-named NPC, but qcat `#a_zombie` already drops `A Sealed Letter`, so it is the closest local Drosco-equivalent. Migration 074 adds Drosco's `Order of Thunder` to that same lootdrop at 12.5%, reusing the existing local chance from the same item on `Kobot Dellin`.

Decision for now: make the item path completable, but revisit Drosco's exact NPC name, placeholder behavior, pathing/despawn, and medal drop chance during a spawn/loot audit.

### Druid Epic full-chain fidelity

- P99 page: `https://wiki.project1999.com/Druid_Epic_Quest`
- Local quest keys: many Classic/Kunark chain NPCs from Telin Darkforest through Xanuusus
- Status: local Lua coverage exists; full chain not marked P99-complete.

The local repo has Lua for many Druid Epic chain NPCs and the final `Nature Walkers Scimitar` reward path, but the page is a large multi-zone chain with forage items, recipe combines, tainted/corrupted placeholder spawns, spawned combat, Venril Sathir remains flow, Faydedar flow, and several intermediate turn-ins.

Decision for now: keep the existing Druid Epic chain enabled, but do not mark it fully P99-aligned until it receives a dedicated end-to-end chain audit.

## Known implementation approximations

### Chalice of Conquest Captain Klunga movement/drop segment

- P99 page: `https://wiki.project1999.com/Chalice_of_Conquest_Quest`
- Local quest keys: `cauldron/Ghilanbiddle_Nylwadil`, `cauldron/#Captain_Klunga`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/cauldron/Ghilanbiddle_Nylwadil.lua`, `server/internal/quest/overrides/lua/converted-perl/cauldron/#Captain_Klunga.lua`
- Status: turn-in path is functional; movement/ground-drop segment remains an IdleQuest simplification.

P99 has Ghilanbiddle spawn Captain Klunga, then the player gives Klunga an orc shovel, follows him across Dagnor's Cauldron, kills him, and picks up the Chalice from the ground. Local IdleQuest currently simplifies this by creating the Chalice ground object immediately from the shovel hand-in in Klunga's existing converted script. This preserves the required item progression but does not yet reproduce the full escort/movement/drop behavior.

Decision for now: accept the simplification for the quest-turn-in audit and revisit if/when quest NPC pathing plus temporary ground spawns are audited as mechanics.

### Cleric Epic 1.0 spawned combat and raid-rule fidelity

- P99 page: `https://wiki.project1999.com/Cleric_Epic_Quest`
- Local quest keys: `lakerathe/Shmendrik_Lavawalker`, `lakerathe/#Natasha_Whitewater`, `timorous/Omat_Vastsea`, `soltemple/a_seeker`, `timorous/Natasha_Whitewater`, `burningwood/Naxot_Deepwater`, `soldungb/Zordak_Ragefire`, `timorous/Jhassad_Oceanson`, `timorous/Avatar_of_Water`
- Status: P99 item progression/rewards are implemented; some spawned-combat behavior is approximated.

The local Cleric Epic 1.0 path now follows the P99 Sol B/Nagafen's Lair Zordak route. The non-P99 Skyfire Warder Cecilia/Zordak path and later Timorous Gefaari Drokaz/Zordak-style combat script are excluded from imported quest content. The remaining differences are mechanical: IdleQuest does not currently reproduce every P99 spawned-NPC combat interaction automatically, and it does not implement P99 raid-rule/FFA policy timing such as the 20-minute Zordakalicus engage rule.

Decision for now: consider the quest item chain and rewards P99-aligned for turn-in testing, while leaving full spawned-combat/raid-policy fidelity for a separate engine mechanics audit.

### Duster Models route/pathing fidelity

- P99 page: `https://wiki.project1999.com/Duster_Models`
- Local quest keys: `akanon/Drekon_Vebnebber`, `akanon/Sanfyrd_Featherhead`, `akanon/Duster_V`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/akanon/Drekon_Vebnebber.lua`, `server/internal/quest/overrides/lua/modified-upstream/akanon/Sanfyrd_Featherhead.lua`, `server/internal/quest/upstream/projecteq/akanon/Duster_V.lua`
- Status: Daily Log spawn trigger and final scrap turn-in fixed; route/pathing/placeholder behavior needs review.

P99 describes Duster V placeholder cycles and Duster X pathing after the Daily Log hand-in. Local Drekon now spawns Duster X and Sanfyrd now rewards the P99 scrap hand-in, but the exact Duster V/Duster X route timing, placeholder behavior, kill coin, and despawn cycle are not proven.

Decision for now: keep the quest completable at the item/turn-in layer, and leave exact moving clockwork behavior for a spawn/pathing audit.

### Enchanter Epic full-chain fidelity

- P99 page: `https://wiki.project1999.com/Enchanter_Epic_Quest`
- Local quest keys: many Classic/Kunark chain NPCs from Stofo Olan through Jeb Lumsed and the four masters
- Status: local Lua coverage exists; full chain not marked P99-complete.

The local repo has Lua for the major Enchanter Epic chain NPCs and final reward path, but the page is a large multi-zone chain with charm-only exchanges, spawned aggro NPCs, flexible Enchanter's Sack combine behavior, and many intermediate item hand-ins.

Decision for now: keep the existing Enchanter Epic chain enabled, but do not mark it fully P99-aligned until it receives a dedicated end-to-end chain audit.

### Entalon charm gate

- P99 page: `https://wiki.project1999.com/Entalon%27s_Quest`
- Local quest key: `burningwood/Entalon`
- Local file: `server/internal/quest/upstream/projecteq/burningwood/Entalon.lua`
- Status: item pair and teleport reward match; charm gate not enforced.

P99 says the player charms Entalon before hailing and completing the turn-in. Local Lua accepts `Scribblings` plus `Stoneleer Emerald Plume` and teleports the player to the expected audience location, but it does not check whether Entalon is charmed.

Decision for now: keep the local turn-in functional and record the missing charm-state gate as a mechanics fidelity gap.

### Eye of Stormhammer bank NPC and full spawn path

- P99 page: `https://wiki.project1999.com/Eye_of_Stormhammer`
- Local quest keys: `kaladima/Beno_Targnarle`, `highkeep/Jail_Clerk_Maryl`, `misty/Bronin_Higginsbot`, `highkeep/Assistant_Kiolna`, `cauldron/Elmion_Hendrys`, `qeynos2/Faldor_Hendrys`
- Status: item chain is locally functional; exact Highkeep bank NPC identity and all rare-spawn steps need review.

P99 says the H.K. 106 key goes to Bank Clerk Jaylin. Local Bronin directs the player to Assistant Kiolna, and local `Assistant_Kiolna.lua` handles H.K. 106 and rewards the Emerald Shard. This may be an acceptable local implementation detail because Kiolna identifies herself as Jaylin's assistant, but it does not exactly match the P99 page text.

Decision for now: keep the local chain enabled and functional, but do not mark the full Eye of Stormhammer experience P99-complete until the bank NPC identity and rare-spawn/loot path are audited end to end.

### Faren's Tacklebox ground item

- P99 page: `https://wiki.project1999.com/Faren%27s_Tacklebox`
- Local quest keys: `qeynos/Guard_Beren`, `qeynos/Faren`, `qeynos/Trumpy_Irontoe`
- Local files: `server/internal/quest/upstream/projecteq/qeynos/Guard_Beren.lua`, `server/internal/quest/overrides/lua/modified-upstream/qeynos/Faren.lua`, `server/internal/quest/upstream/projecteq/qeynos/Trumpy_Irontoe.lua`, `server/internal/quest/upstream/projecteq/qeynos/encounters/trumpy.lua`
- Status: final hand-in reward corrected; required tacklebox source not found.

P99 has Trumpy knock Faren's tacklebox into the water, after which the player retrieves and returns it. Local Faren's final hand-in now rewards Hurrieta's Tunic and exactly 9 copper, but `Wooden Fishing Tackle` item `13702` was not found in local static object rows or loot rows during this batch.

Decision for now: keep the corrected final hand-in and record the missing underwater ground-object spawn for a dedicated object/spawn mechanics pass.

### Gnasher's Head random armor/coin details

- P99 page: `https://wiki.project1999.com/Gnasher%27s_Head`
- Local quest keys: `qrg/Larsk_Juton`, `qeynos/Captain_Tillin`, `qeytoqrg/Gnasher_Furgutt`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/qrg/Larsk_Juton.lua`, `server/internal/quest/overrides/lua/modified-upstream/qeynos/Captain_Tillin.lua`, `server/internal/quest/upstream/projecteq/qeytoqrg/Gnasher_Furgutt.lua`
- Status: final Captain Tillin reward fixed; Larsk exact random armor/coin table needs review.

P99 documents Larsk's Gnoll Head reward as gold, silver, copper, and a random low-level armor piece, with Raw-hide Tunic shown as the observed/example reward. Local keeps the ProjectEQ Raw-hide Tunic reward and removes platinum from the random coin. Larsk's first-note hand-in now also awards the P99-documented factions and non-platinum random coin.

Decision for now: align the clear no-platinum and final Captain Tillin exact reward behavior, but keep the local Raw-hide Tunic reward until another source confirms the full P99 low-level armor pool.

### Gnoll Bounty minor item and coin randomness

- P99 page: `https://wiki.project1999.com/Gnoll_Bounty`
- Local quest key: `halas/Lysbith_McNaff`
- Local file: `server/internal/quest/upstream/projecteq/halas/Lysbith_McNaff.lua`
- Status: local behavior is within the P99 documented broad range; no Lua change made.

P99 documents 2-5 gold and a minor item, listing Iron Ration, Ration, Torch, and Water Flask. Local ProjectEQ-derived Lua gives 5 gold and Iron Ration. This fits the documented max coin and one documented minor item, but it is not a full randomized reward pool.

Decision for now: keep the deterministic local reward until another source confirms the P99 randomization table.

### Gnoll Scalp Collecting exact EXP/coin

- P99 page: `https://wiki.project1999.com/Gnoll_Scalp_Collecting`
- Local quest keys: `highpass/Captain_Orben`, `highpasshold/Captain_Orben`
- Local files: `server/internal/quest/upstream/projecteq/highpass/Captain_Orben.lua`, `server/internal/quest/upstream/projecteq/highpasshold/Captain_Orben.lua`
- Status: local one-to-four scalp mechanics and faction direction match; exact values need review.

P99 documents that Captain Orben accepts one to four Gnoll Scalps, awards coin from 4 silver up to 1 platinum, gives experience, and changes the shady Highpass factions. Local has both Highpass zone aliases with compatible hand-ins, but the two scripts use different ProjectEQ-derived EXP values and broad coin behavior.

Decision for now: keep both aliases functional and defer exact coin/EXP tuning until a better P99 or classic source gives exact values.

### Goblin Caster Necklace shattered-beads reward

- P99 page: `https://wiki.project1999.com/Goblin_Caster_Necklace`
- Local quest key: `halas/Shamus_Felligan`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/halas/Shamus_Felligan.lua`
- Status: faction gate and dialogue corrected; exact shattered-beads coin/minor reward needs review.

P99 says Shamus requires amiable or better faction. It clearly documents Gavel of Justice for pristine Caster Beads. For Shattered Caster Beads, it says the player receives faction, experience, coin, and a minor item, but does not list the exact coin or minor-item table. Local keeps the ProjectEQ-derived shaman spell reward pool for shattered beads and does not invent coin.

Decision for now: add the clear faction gate and P99 shattered-beads text, keep the local spell reward pool, and revisit coin/minor reward details if another source confirms them.

### Goblin Raiders minor reward pool

- P99 page: `https://wiki.project1999.com/Goblin_Raiders`
- Local quest key: `firiona/Captain_Keatar`
- Local file: `server/internal/quest/overrides/lua/idlequest-authored/firiona/Captain_Keatar.lua`
- Status: missing local quest implemented; exact minor reward pool needs review.

P99 documents the reward as "Minor Items (e.g, Wooden Shield and 8 gold)" and explicitly says the list of quest rewards is still needed. Local implements the documented example reward: Wooden Shield plus 8 gold, faction, and experience.

Decision for now: use the only documented example reward so the quest is functional, and revisit if a full P99 reward table is found.

### Guard of Ik exact faction/EXP values

- P99 page: `https://wiki.project1999.com/Guard_of_Ik_Quest`
- Local quest key: `firiona/Gearin_Gaxx`
- Local file: `server/internal/quest/overrides/lua/converted-perl/firiona/Gearin_Gaxx.lua`
- Status: missing final turn-in implemented; exact faction/EXP amounts need review.

P99 documents the two Trooper Shield plus Scribbled Note hand-in, Guard of Ik reward, Firiona Vie / Emerald Warriors / Storm Guard faction increases, Legion of Cabilis / Pirates of Gunthak decreases, and experience. It does not provide exact faction or EXP amounts. Local uses conservative +1/-1 faction changes and a small EXP award.

Decision for now: make the item path completable and P99-directionally correct, but defer exact amount tuning.

### Langseax final faction amounts

- P99 page: `https://wiki.project1999.com/Langseax_Quest`
- Local quest key: `halas/Renth_McLanis`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/halas/Renth_McLanis.lua`
- Status: final hand-ins corrected to require only Basil's Head or Paglan's Head; exact faction amounts kept from local ProjectEQ-derived behavior.

P99 documents that Renth accepts Basil's Head for Langseax and Paglan's Head for Langseax of the Wolves plus 4 platinum. It shows negative faction direction for Wolves of the North, Shamen of Justice, Merchants of Halas, and Steel Warriors, but does not provide exact numerical amounts.

Decision for now: use the clear P99 item/reward/cash behavior, keep local negative faction amounts, and revisit only if exact P99 values are found.

### Leatherfoot Raiders exact faction/coin/EXP values

- P99 page: `https://wiki.project1999.com/Leatherfoot_Raiders`
- Local quest key: `rivervale/Marshal_Anrey`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/rivervale/Marshal_Anrey.lua`
- Status: P99 turn-in text and faction directions corrected; final reward remains the clickable local `Leatherfoot Raider Skullcap` item `12259`.

P99 documents the faction directions for both hand-ins and notes the quest requires amiable-or-better faction. It does not document exact numeric faction, coin, or experience amounts. Local keeps the ProjectEQ-derived coin/EXP values and numeric faction amounts, but removes the undocumented first-step Merchants of Rivervale faction increase and adds the faction gate.

Decision for now: align the clear P99 dialogue/faction-direction mechanics while preserving local numeric rewards pending a more exact P99/classic source.

### Legion Lager Quest missing Trooper Neozite source

- P99 page: `https://wiki.project1999.com/Legion_Lager_Quest`
- Local quest key: not found
- Local file: not found
- Status: no Lua added.

The P99 page is marked unsolved and says Trooper Neozite was possibly removed from the game. Local data has `Legion Lager` item `12463` and the brewing recipe, but no `Trooper Neozite` NPC row or local quest script was found during this batch.

Decision for now: do not invent a missing NPC, spawn, or reward from an unsolved page. Leave this as a review item unless a stronger classic/P99 source confirms Trooper Neozite's spawn and quest behavior.

### Lenka's Pouch L.S. Pouch ground-spawn placement

- P99 page: `https://wiki.project1999.com/Lenka%27s_Pouch`
- Local quest keys: `freportw/Toala_Nehron`, `freeporteast/Toala_Nehron`, `freporte/Lenka_Stoutheart`, `freeporteast/Lenka_Stoutheart`, `freporte/Brunar_Rankin`, `freeporteast/Brunar_Rankin`, `freporte/Olunea_Miltin`, `freeporteast/Olunea_Miltin`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/freportw/Toala_Nehron.lua`, `server/internal/quest/overrides/lua/modified-upstream/freeporteast/Toala_Nehron.lua`, `server/internal/quest/overrides/lua/modified-upstream/freporte/Brunar_Rankin.lua`, `server/internal/quest/overrides/lua/modified-upstream/freeporteast/Brunar_Rankin.lua`
- Migration: `server/migrations/081_add_l_s_pouch_ground_spawn.sql`
- Status: wrong Toala pouch turn-in removed; Classic Brunar clue dialogue restored; L.S. Pouch ground-spawn source added with approximate placement.

P99 documents L.S. Pouch as a ground spawn in the Seafarer's Roost basement, behind crates near the fake wall into the evil guild area, but does not provide an exact `/loc`. Local had no `ground_spawns` or `object` source for item `13814`.

Decision for now: add old/new East Freeport ground-spawn rows near the local tavern area with comments marking the placement approximate. This should be inspected in-game and moved if the pouch is not in the correct basement/fake-wall room.

### Lizard low-level reward pools and faction amounts

- P99 pages: `https://wiki.project1999.com/Lizard_Dolls`, `https://wiki.project1999.com/Lizard_Tails`, `https://wiki.project1999.com/Lizard_Tails_No_2`
- Local quest keys: `oggok/Grevak`, `oggok/Horgus`
- Local files: `server/internal/quest/overrides/lua/converted-perl/oggok/Grevak.lua`, `server/internal/quest/overrides/lua/converted-perl/oggok/Horgus.lua`
- Status: clear item/coin/faction direction mismatches corrected; exact random minor-item pools and faction amounts remain approximate.

P99 documents broad low-level rewards: Grevak's Lizard Dolls can give Backpack and low-level necromancer spell scrolls, Grevak's Lizard Tails gives 6 silver plus a tattered armor piece, and Horgus gives a Raw-hide Armor piece. It does not document complete random tables or exact faction amounts.

Decision for now: use the documented reward categories with available Classic item rows and conservative local faction/EXP amounts. Revisit only if a complete P99 reward table or live-test evidence is found.

### Lionskin Gloves faction gate

- P99 page: `https://wiki.project1999.com/Lionskin_Gloves_Quest`
- Local quest key: `kithicor/Ged_Twigborn`
- Local file: `server/internal/quest/overrides/lua/converted-perl/kithicor/Ged_Twigborn.lua`
- Status: local hand-in item/cost/reward match; no Lua change made.

P99 says the quest requires high faction with Ged, but the page is incomplete and does not identify an exact required faction threshold or failure text. Local converted ProjectEQ Lua implements the High Quality Lion Skin plus 96 gold hand-in and rewards Lionskin Gloves.

Decision for now: keep the functional local hand-in unchanged until a stronger source confirms the exact faction gate behavior.

### Long Iron Rod unsolved combine

- P99 page: `https://wiki.project1999.com/Long_Iron_Rod_Quest`
- Local recipe IDs: `5402`, `9875`
- Migration: `server/migrations/073_enable_p99_classic_quest_combines.sql`
- Status: disabled local recipes enabled as no-fail quest combines.

P99 marks this Kunark Dalnir page as unsolved and says more dialogue/faction/reward information is needed, but the documented mechanic is a concrete combine: Rod Segment 'I', Rod Segment 'II', and Forge Hammer of Dalnir in an Always Works forge produce Long Iron Rod. The required local drop rows exist.

Decision for now: enable the imported no-fail recipes so the documented combine works. Do not invent extra dialogue, faction, or reward behavior beyond the P99 combine.

### Lord Grimrot / Grimlot's Love impossible quest

- P99 page: `https://wiki.project1999.com/Lord_Grimlot%27s_Love`
- Local quest key: `southkarana/Lord_Grimrot`
- Local file: `server/internal/quest/overrides/lua/converted-perl/southkarana/Lord_Grimrot.lua`
- Status: no reward path added.

P99 documents this as an early/beta or patched-out quest that was never fully implemented on P99 and should be expected to be impossible to complete. Local Grimrot dialogue exists for the larger Grimrot/Bloodsaber context.

Decision for now: keep local dialogue/context but do not add the unconfirmed Electrum-Bladed Wakizashi or any invented Arlena/bones reward path.

### Lydl Mastat EXP and spawn aliases

- P99 page: `https://wiki.project1999.com/Lydl_Mastat`
- Local quest keys: `freportw/Hemia_Skemner`, `freeportwest/Hemia_Skemner`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/freportw/Hemia_Skemner.lua`, `server/internal/quest/overrides/lua/modified-upstream/freeportwest/Hemia_Skemner.lua`
- Status: P99 amiable-or-better faction gate added; existing local coin/EXP kept.

P99's page lists experience in the walkthrough but also includes player notes that the quest gave no experience for level 4 characters. Local ProjectEQ-derived behavior gives a small EXP award. Local also has several Lydl spawn rows across old Freeport/Highpass/North Ro era-alias data; the classic Freeport rows have the 100% Locked Book drop and P99-directional kill faction.

Decision for now: enforce the clear amiable-or-better gate and keep the local EXP/coin behavior pending stronger evidence. Do not alter Lydl spawn rows in this batch.

### Lynuga's Gem Collection reward rarity

- P99 page: `https://wiki.project1999.com/Lynuga%27s_Gem_Collection`
- Local quest keys: `innothule/Lynuga`, `innothuleb/Lynuga`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/innothule/Lynuga.lua`, `server/internal/quest/overrides/lua/modified-upstream/innothuleb/Lynuga.lua`
- Status: reward weighting changed to Brutechopper common, Midnight Mallet rare, and Ivandyr's Hoop ultra-rare.

P99 documents the relative reward rarity but not exact percentages, and notes the Hoop was made rarer due to balance issues.

Decision for now: use a conservative approximate table of 90% Brutechopper, 9% Midnight Mallet, and 1% Ivandyr's Hoop so the mechanics match P99 directionally without claiming exact live odds.

### Magic Elixir reward pool and faction threshold

- P99 page: `https://wiki.project1999.com/Magic_Elixir_for_the_Warriors`
- Local quest keys: `halas/Dargon_McPherson`, `everfrost/Talin_O-Donal`, `everfrost/Bryndin_McMill`, `everfrost/Arnis_McLish`, `everfrost/Megan_OReilly`, `everfrost/Snowflake`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/halas/Dargon_McPherson.lua`, `server/internal/quest/overrides/lua/modified-upstream/everfrost/Talin_O-Donal.lua`, `server/internal/quest/overrides/lua/modified-upstream/everfrost/Bryndin_McMill.lua`, `server/internal/quest/overrides/lua/modified-upstream/everfrost/Arnis_McLish.lua`, `server/internal/quest/overrides/lua/modified-upstream/everfrost/Megan_OReilly.lua`
- Status: Dargon now starts/completes the quest at apprehensive-or-better faction, final coin is 1-3 copper, the random reward pool is restricted to the P99-listed items, and missing intermediate hail text was added.

P99 says the quest can be started at apprehensive and documents the final reward as 1-3 copper plus a random low-level item from a listed set. Local ProjectEQ-derived behavior previously required better faction for the start and used a larger unrelated random reward pool.

Decision for now: align the clear faction threshold, listed item pool, and coin range. Keep ProjectEQ-derived numeric faction/EXP amounts unless exact P99 values are found.

### Magician Plane of Sky Tests starter book flow

- P99 page: `https://wiki.project1999.com/Magician_Plane_of_Sky_Tests`
- Local quest keys: `airplane/Magus_Frinon`, `airplane/Frederic_Calermin`, `airplane/Roanis_Elindar`
- Local files: `server/internal/quest/upstream/projecteq/airplane/Magus_Frinon.lua`, `server/internal/quest/upstream/projecteq/airplane/Frederic_Calermin.lua`, `server/internal/quest/upstream/projecteq/airplane/Roanis_Elindar.lua`
- Status: tester hand-ins match; Frinon start flow kept simplified.

P99 documents Magus Frinon giving a `Forms of Magic` tome and the player returning the tome to summon the selected tester. Local Frinon currently spawns Frederic or Roanis directly from the dialogue choice. The local DB has one `Forms of Magic` item row, but the P99 page does not clearly document enough separate item/state data to reproduce both tester choices without adding quest state.

Decision for now: keep the simplified local starter flow because the actual Sky test hand-ins and rewards are present and functional. Revisit if exact book-return mechanics become important for in-game fidelity.

### Mammoth Calf Hides faction threshold

- P99 page: `https://wiki.project1999.com/Mammoth_Calf_Hides`
- Local quest key: `halas/Cappi_McTarnigal`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/halas/Cappi_McTarnigal.lua`
- Status: low-faction rejection added; exact threshold needs review.

P99 documents a low-faction rejection line but does not give the exact faction threshold. The local script previously accepted four Mammoth Calf Hides from anyone.

Decision for now: require amiable-or-better faction, matching the common local convention used by similar P99-audited guild quests. Keep the exact threshold as review-needed unless a stronger P99/classic source gives it.

### Mammoth Tusks reward pool and Noxhil combine chain

- P99 page: `https://wiki.project1999.com/Mammoth_Tusks_Quest`
- Related P99 page: `https://wiki.project1999.com/Fire_Beetle_Eyes`
- Local quest key: `neriakc/Noxhil_V-Sek`
- Local file: `server/internal/quest/overrides/lua/converted-perl/neriakc/Noxhil_V-Sek.lua`
- Migration: `server/migrations/073_enable_p99_classic_quest_combines.sql`
- Status: final hand-in corrected; exact reward pool/EXP/faction amounts need review.

P99 says Mammoth Tusks requires the combined `Beetle Eye Chest` plus `Mammoth Tusks`. Local Noxhil previously accepted two Mammoth Tusks without the combined chest. P99 also says the reward is low-level necromancer spells and gives `Spell: Engulfing Darkness` as the observed example, but says additional quest rewards are still needed.

Decision for now: make the mechanic require the combined Beetle Eye Chest plus Mammoth Tusks, give the documented example `Spell: Engulfing Darkness`, and avoid inventing an unproven random spell table. Migration 073 also enables the disabled `Box Of Beetle Eyes` combine needed by Noxhil's preceding Fire Beetle Eyes quest.

### Marda's Secret Mission broken Dorn branch

- P99 page: `https://wiki.project1999.com/Marda%27s_Secret_Mission`
- Local quest keys: `oggok/Marda`, `oggok/Emissary_Glib`, `grobb/a_prisoner`, `innothule/Forager_Grik`, `innothuleb/Forager_Grik`
- Local files: `server/internal/quest/overrides/lua/converted-perl/oggok/Marda.lua`, `server/internal/quest/overrides/lua/converted-perl/oggok/Emissary_Glib.lua`, `server/internal/quest/upstream/projecteq/grobb/a_prisoner.lua`, `server/internal/quest/upstream/projecteq/innothule/Forager_Grik.lua`, `server/internal/quest/upstream/projecteq/innothuleb/Forager_Grik.lua`
- Status: successful Zimbittle branch kept; no Lua change made.

P99 documents an alternate Dorn B`Dynn note branch, but the same page says this branch is broken on P99/live because Marda does not accept the returned note. Local currently always gives the completable Zimbittle note from the prisoner and does not randomize in the broken Dorn branch.

Decision for now: keep the player-facing chain completable and do not add a random broken branch. Revisit only if the goal becomes reproducing P99's broken note behavior exactly.

### Marr Minnows for Palon faction threshold

- P99 page: `https://wiki.project1999.com/Marr_Minnows_for_Palon`
- Local quest keys: `freportw/Palon_Deskeb`, `freeportwest/Palon_Deskeb`, `freportn/a_minnow`, `freeportwest/a_minnow`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/freportw/Palon_Deskeb.lua`, `server/internal/quest/overrides/lua/modified-upstream/freeportwest/Palon_Deskeb.lua`, `server/internal/quest/upstream/projecteq/freportn/a_minnow.lua`, `server/internal/quest/upstream/projecteq/freeportwest/a_minnow.lua`
- Status: Palon now gates Jar of Liquid dialogue at kindly-or-better faction, adds the P99 final text, and adds the P99-observed 10 silver/6 copper reward.

P99 says Palon would not give the jar at amiable faction and says the player must prove their worth with Tara Neklene or Rephas, but it does not provide the exact faction tier or failure text. Local faction levels are numeric, with amiable as 4 and kindly as 3.

Decision for now: require `GetFaction(e.self) < 4`, meaning kindly or better. The low-faction rejection text is local explanatory text because P99 does not show the actual rejection line.

### Package from Lomarc timing and placeholder behavior

- P99 page: `https://wiki.project1999.com/Package_from_Lomarc`
- Local quest keys: `qeynos2/Renux_Herkanor`, `qeynos/Lomarc`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/qeynos2/Renux_Herkanor.lua`, `server/internal/quest/overrides/lua/modified-upstream/qeynos/Lomarc.lua`
- Migration: `server/migrations/088_enable_p99_quest_combines_and_lomarc_loot.sql`
- Status: quest made mechanically completable; exact nighttime/placeholder gating not implemented.

P99 says Renux sends the player to Lomarc after a rogue-guild signal conversation, and Lomarc is a night-only spawn sharing a route/placeholder with Den Magason. Local Renux previously only had signal chatter and Lomarc had no quest hand-in or Kerran Doll loot.

Decision for now: Renux gives `Lomarc's Payment`, Lomarc attacks when handed it, and Lomarc now drops `Kerran Doll` at 100%. Do not block the quest behind the night-only Den Magason placeholder until IdleQuest has a stronger spawn-time/placeholder model for that specific Qeynos route.

### Paladin Plane of Sky Tests starter book flow

- P99 page: `https://wiki.project1999.com/Paladin_Plane_of_Sky_Tests`
- Local quest keys: `airplane/Dason_Goldblade`, `airplane/Gregori_Lightbringer`, `airplane/Dirkog_Steelhand`
- Local files: `server/internal/quest/upstream/projecteq/airplane/Dason_Goldblade.lua`, `server/internal/quest/overrides/lua/modified-upstream/airplane/Gregori_Lightbringer.lua`, `server/internal/quest/upstream/projecteq/airplane/Dirkog_Steelhand.lua`
- Status: tester hand-ins corrected; Dason starter flow remains simplified.

P99 documents Dason giving books and summoning Gregori/Dirkog after a returned book. Local Dason directly spawns the selected tester from dialogue. The actual reward hand-ins are the quest-critical part, and Gregori's Love test was corrected from the old `Zephyrwind` reward to `Thelvorn, Blade of Light`.

Decision for now: keep Dason's direct-summon flow and audit the hand-ins/rewards as functional. Revisit the book-return flow only if starter-state fidelity becomes important.

### Paw of Opolla fungus mutant drop-rate estimates

- P99 page: `https://wiki.project1999.com/Paw_of_Opolla_Quest`
- Local quest keys: `qey2hh1/Caninel`, `qeynos/Micc_Koter`, `qcat/Vin_Moltor`, `kerraridge/Melixis`
- Local files: `server/internal/quest/upstream/projecteq/qey2hh1/Caninel.lua`, `server/internal/quest/upstream/projecteq/qeynos/Micc_Koter.lua`, `server/internal/quest/overrides/lua/converted-perl/qcat/Vin_Moltor.lua`, `server/internal/quest/overrides/lua/converted-perl/kerraridge/Melixis.lua`
- Migration: `server/migrations/088_enable_p99_quest_combines_and_lomarc_loot.sql`
- Migration: `server/migrations/104_align_p99_paw_opolla_fungus_mutant_drops.sql`
- Status: missing combines enabled; source drops present; fungus mutant quest-material rates matched to P99's rough estimates.

P99 gives rough fungus mutant drop-rate estimates of about 75% `Guk Bracket Mildew`, 20% `Faerix Spores`, and 5% `Degenerated Guk Weed`. Local data already has all three drops and the Melixis exchanges; migration 104 changes the local dedicated Opolla material lootdrop to those weights.

Decision: enable the disabled Rat Ear Pie and Paw Of Opolla combines so the quest is completable, and tune `a_fungus_mutant`'s dedicated Opolla quest-material lootdrop to exactly one weighted drop at 75/20/5. This preserves unrelated fungus mutant loot while making the quest-material kill rates match P99's documented rough estimates.

### Piranha Hunting unspecified minor reward item

- P99 page: `https://wiki.project1999.com/Piranha_Hunting`
- Local quest keys: `freportn/Celsar_Vestagon`, `freeportwest/Celsar_Vestagon`
- Local files: `server/internal/quest/upstream/projecteq/freportn/Celsar_Vestagon.lua`, `server/internal/quest/upstream/projecteq/freeportwest/Celsar_Vestagon.lua`
- Migration: `server/migrations/088_enable_p99_quest_combines_and_lomarc_loot.sql`
- Status: missing combine enabled; random minor item reward not added.

P99 says the reward is faction, small coin, and occasionally a cleric spell or potion, but the page does not provide a concrete stable item list. Local Celsar already has the faction and copper reward, and Fresh Piranha drops exist locally.

Decision for now: enable the disabled `Sack Of Piranha` combine and keep the known faction/copper reward. Do not invent a random minor-item pool without a stronger item list.

### Plaguebringer Proof Tovax letter source

- P99 page: `https://wiki.project1999.com/Plaguebringer_Proof`
- Local quest keys: `qeynos2/Roesager_Thusten`, `qcat/Sragg_Bloodheart`, `qeytoqrg/Tovax_Vmar`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/qeynos2/Roesager_Thusten.lua`, `server/internal/quest/overrides/lua/converted-perl/qcat/Sragg_Bloodheart.lua`, `server/internal/quest/overrides/lua/idlequest-authored/qeytoqrg/Tovax_Vmar.lua`
- Status: good/evil proof hand-ins added; exact Tovax timed/pathing ground-drop behavior approximated.

P99 documents Tovax as dropping the `Sealed Letter` on the ground during a night pathing cycle. Local DB has Tovax spawned in Qeynos Hills, but no script or loot source for the letter.

Decision for now: add a Tovax script that creates the `Sealed Letter` as a character-scoped ground object when Tovax dies, then let Roesager, Sragg, or Tovax consume that letter for the documented branches. This keeps the letter as a ground object instead of normal shared loot, but does not reproduce P99's timed/path stop behavior.

### Poacher Erudin reward pool

- P99 page: `https://wiki.project1999.com/Poacher%27s_Head_Quest_(Erudin)`
- Related P99 page: `https://wiki.project1999.com/Poacher_Leader`
- Local quest key: `erudnext/Jras_Solsier`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/erudnext/Jras_Solsier.lua`
- Status: Poacher's Head reward pool updated; Poacher Leader spell pool remains approximate.

P99 lists Poacher's Head rewards as Copper Band, Malachite, Fishing Spear, Rusty Rapier, Small Lantern, small coin, faction, and experience. It lists Poacher Leader's Barbarian Head reward only as a random low-level spell without the concrete spell list.

Decision for now: use the listed minor item pool for Poacher's Head and keep a small random copper reward. Keep the existing `Spell: Holy Armor` reward for Barbarian Head until a stronger P99/classic source gives the full random spell table.

### Preserved Meat Delivery reward weights

- P99 page: `https://wiki.project1999.com/Preserved_Meat_Delivery`
- Local quest keys: `oggok/Chef_Dooga`, `neriaka/The_Gobbler`
- Local files: `server/internal/quest/overrides/lua/converted-perl/oggok/Chef_Dooga.lua`, `server/internal/quest/overrides/lua/converted-perl/neriaka/The_Gobbler.lua`
- Status: coin and guaranteed reward item behavior updated; exact reward odds approximate.

P99 says the Gobbler gives 1-5 gold and one random reward from Star Rose Quartz, Ogre Meat Cleaver, and very rare Ogre Butcher Gloves, but it does not give exact reward odds.

Decision for now: always give one of the listed items, weighted toward Star Rose Quartz with Ogre Butcher Gloves rare, and use the documented 1-5 gold range.

### Putrid Skeletons Jahnda reward weighting

- P99 page: `https://wiki.project1999.com/Putrid_Skeletons`
- Local quest keys: `qeynos2/Roesager_Thusten`, `qeytoqrg/Niclaus_Ressinn`, `qeynos2/Priestess_Jahnda`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/qeynos2/Roesager_Thusten.lua`, `server/internal/quest/overrides/lua/modified-upstream/qeytoqrg/Niclaus_Ressinn.lua`, `server/internal/quest/overrides/lua/modified-upstream/qeynos2/Priestess_Jahnda.lua`
- Status: missing coin/faction and final reward mechanics updated; exact rare reward weighting approximate.

P99 documents Niclaus' note, rib bone, and Jahnda pouch steps with concrete faction directions and coin values. For Jahnda's random item, P99 lists Potion of Light Healing, Potion of Disease Warding, Shield of Nife, and Skullcap of Rodcet Nife, with one recorded sample showing 15/24 Light, 7/24 Disease, 2/24 Shield, and 0/24 Skullcap.

Decision for now: use the documented fixed coin and faction values, and approximate the random reward over 24 slots while still allowing the listed Skullcap as a rare outcome. Revisit if a stronger source gives exact server odds.

### Qeynos Badge and Quellious Symbol later-era exposure

- P99 pages: `https://wiki.project1999.com/Qeynos_Badge_Quests`, `https://wiki.project1999.com/Quellious_Symbol_Quests`
- Local quest keys: `qeynos2/Vegalys_Keldrane`, `erudnext/Leraena_Shelyrak`
- Local files: `server/internal/quest/upstream/projecteq/qeynos2/Vegalys_Keldrane.lua`, `server/internal/quest/overrides/lua/modified-upstream/erudnext/Leraena_Shelyrak.lua`, `server/internal/quest/content_exclusions.json`
- Status: Qeynos Badge disabled; Quellious Symbol remains out of scope with branch already removed.

P99 marks both pages as Warrens/Fear-Hate-revamp-era or Warrens-era content. Vegalys' local script only exposes the later badge chain, while Leraena has Classic starting-note/guild-coin content in addition to the later symbol branches.

Decision for now: exclude `qeynos2/Vegalys_Keldrane` at import. Do not disable Leraena wholesale; her modified-upstream override already omits the Warrens/Stonebrunt branches while preserving Classic Erudin cleric content.

### Recharge Prayer Beads trade-state approximation

- P99 page: `https://wiki.project1999.com/Recharge_Prayer_Beads`
- Local quest key: `qeynos2/Tyokan_Mekase`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/qeynos2/Tyokan_Mekase.lua`
- Status: implemented as a same-transaction hand-in.

P99 documents a two-step NPC trade state: hand Tyokan used `Prayer Beads`, then hand him 100 gold, and receive recharged `Prayer Beads`. IdleQuest's current quest runtime does not support safe per-NPC pending trade state for this style of recharge.

Decision for now: require `Prayer Beads` plus 100 gold in the same turn-in. This prevents partial turn-ins from eating either the item or the gold while still making the quest mechanically available.

### Rathmana's Traveling Offer Force Shock reward

- P99 page: `https://wiki.project1999.com/Rathmana%27s_Traveling_Offer`
- Local quest keys: `southro/Rathmana_Allin`, `sro/Rathmana_Allin`
- Local files: `server/internal/quest/upstream/projecteq/southro/Rathmana_Allin.lua`, `server/internal/quest/upstream/projecteq/sro/Rathmana_Allin.lua`
- Status: local script left unchanged pending missing-item/name-equivalence review.

P99 lists `Spell: Force Shock` as one of Rathmana's random scroll rewards. Local ProjectEQ-derived Lua uses `Spell: Force Snap` item `15022`, and the IdleQuest database has no item row named `Spell: Force Shock`.

Decision for now: do not alter Rathmana's reward pool until it is clear whether P99's Force Shock is equivalent to local Force Snap, or whether IdleQuest should add a missing item row.

### Elemental Mastery staff Hate loot-source breadth

- P99 pages: `https://wiki.project1999.com/Staff_of_Elemental_Mastery:_Earth`, `https://wiki.project1999.com/Staff_of_Elemental_Mastery:_Fire`
- Local item IDs: `11567` Staff of Elemental Mastery: Earth, `11566` Staff of Elemental Mastery: Fire
- Status: item rows and local loot sources exist; local Hate loot is broader than the P99 item pages.

P99's Earth staff page lists Innoruuk (prevamp) and Magi P`Tasa. Local data also links the Earth staff to multiple `a_forsaken_revenant` rows. P99's Fire staff page lists Mistress of Scorn and male `a_forsaken_revenant`; local data also links Fire to Magi P`Tasa and many revenant rows.

Decision for now: do not silently retune raid loot from item pages during the quest-turn-in pass. Revisit as a focused epic loot-source audit if the goal becomes P99 raid/source fidelity, because changing Hate loot affects more than one quest turn-in script.

### Talym Shoontar head drop chance

- P99 page: `https://wiki.project1999.com/Talym_Shoontar%27s_Head`
- Local quest key: `qrg/Hager_Sureshot`
- Local item ID: `13913` Barbarian Head
- Status: turn-in matches; local drop chance not changed.

P99 documents killing Talym Shoontar and looting his head, but does not give a clear drop-rate statement. Local Talym rows have non-guaranteed Barbarian Head loot chances.

Decision for now: keep Hager's P99 bounty turn-in as-is and leave Talym's drop rates unchanged until a stronger P99 source says the head should be guaranteed.

### The Broodling unsolved Charasis Tome chain

- P99 page: `https://wiki.project1999.com/The_Broodling`
- Local quest keys: none enabled for the documented death/spawn chain
- Status: no implementation change.

P99 marks this Classic page as unsolved and says killing Dorn B`Dynn may spawn a dark elf spy, then a spider-like broodling, ending in a Charasis Tome. The page lacks exact spawned NPC names, item/reward IDs, dialogue, faction, and a clear reliable trigger.

Decision for now: do not invent the death-spawn chain. Keep it logged as ambiguous Classic content that needs stronger evidence before implementation.

### The Burning Dead unsolved Wand versus Red Sash evidence

- P99 page: `https://wiki.project1999.com/The_Burning_Dead`
- Local quest keys: `freeportwest/Reyia_Beslin`, `freeportwest/Opal_Darkbriar`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/freeportwest/Reyia_Beslin.lua`
- Status: Red Sash destruction path exists; Opal/Wand construction left unimplemented.

P99 marks this page as unsolved and says the Wand of the Burning Dead creation path is widely presumed broken. The concrete Classic evidence on the page is Reyia Beslin's Red Sash path, where the player turns in Marnek's Wand, Sapphire of Souls, and Orange Sash of Order to receive the Red Sash of Order. Local Reyia implements that concrete path.

Decision for now: do not add an Opal Darkbriar wand-creation turn-in. Treat the actual Wand of the Burning Dead construction as unresolved/broken content until a stronger source gives exact working mechanics.

### The Clothspinner Sisters good reward uncertainty

- P99 page: `https://wiki.project1999.com/The_Clothspinner_Sisters_(good)`
- Local quest keys: `qeynos2/Astaed_Wemor`, `qeynos2/Nerissa_Clothspinner`, `eastkarana/Milea_Clothspinner`, `eastkarana/#Guard_Elias`
- Local files: `server/internal/quest/overrides/lua/modified-upstream/qeynos2/Astaed_Wemor.lua`, `server/internal/quest/upstream/projecteq/qeynos2/Nerissa_Clothspinner.lua`, `server/internal/quest/overrides/lua/modified-upstream/eastkarana/Milea_Clothspinner.lua`
- Status: local chain is implemented; exact P99 final random reward evidence is incomplete.

P99 documents the good Clothspinner chain through Nerissa, Milea, Guard Elias, and Astaed, but the page is incomplete about exact reward details. Local scripts implement the chain and return a small random bronze-weapon reward from Astaed.

Decision for now: keep the existing reward pool until stronger P99 evidence gives an exact reward.

### Fiery Avenger Lich charm requirement

- P99 page: `https://wiki.project1999.com/The_Fiery_Avenger`
- Local quest keys: `neriakb/Rysva_To-Biath`, `oot/Oracle_of_K-Arnon`, `everfrost/Lich_of_Miragul`, `airplane/Dason_Goldblade`, `airplane/Dirkog_Steelhand`, `airplane/Inte_Akera`
- Local files: `server/internal/quest/overrides/lua/converted-perl/neriakb/Rysva_To-Biath.lua`, `server/internal/quest/overrides/lua/converted-perl/oot/Oracle_of_K-Arnon.lua`, `server/internal/quest/upstream/projecteq/everfrost/Lich_of_Miragul.lua`, `server/internal/quest/upstream/projecteq/airplane/Dason_Goldblade.lua`, `server/internal/quest/upstream/projecteq/airplane/Dirkog_Steelhand.lua`, `server/internal/quest/overrides/lua/modified-upstream/airplane/Inte_Akera.lua`
- Status: quest item chain exists; charm-gated Lich hand-in is simplified.

P99 requires charming Lich of Miragul before handing in Miragul's Phylactery. Local Lua accepts the phylactery hand-in directly and spawns Miragul, which then drops Miragul's Head and Robe. The rest of the Plane of Sky Inte Akera blessing/final turn-ins are present.

Decision for now: leave the direct Lich hand-in in place. Implementing charm-gated hostile NPC hand-ins is a broader combat/AI/runtime mechanic and should be handled separately if exact P99 encounter behavior becomes the target.

### The Loom incomplete Kunark page

- P99 page: `https://wiki.project1999.com/The_Loom`
- Local quest keys: none
- Status: no implementation change.

P99 marks this as Kunark Era, but the page is incomplete: reward is unknown, no turn-in item IDs are documented, and the walkthrough only states that Dionin Needlespin discusses an unavailable loom and hints at an old one in Kaesora.

Decision for now: do not invent a turn-in or reward. Treat this as unresolved Kunark content until stronger evidence identifies actual quest mechanics.

### The Lost Circle faction/experience amounts

- P99 page: `https://wiki.project1999.com/The_Lost_Circle`
- Local quest key: `dreadlands/Brother_Balatin`
- Local file: `server/internal/quest/overrides/lua/converted-perl/dreadlands/Brother_Balatin.lua`
- Status: final robe reward now applies P99 faction directions and experience; exact amounts approximate.

P99 documents the Robe of the Whistling Fists reward plus positive Whistling Fist Brotherhood and Combine Empire faction, negative Swift Tails faction, and experience. It does not provide exact faction or experience values.

Decision for now: apply conservative faction adjustments and a small experience reward rather than leaving the confirmed reward side effects absent.

### The Gnome Take reward odds

- P99 page: `https://wiki.project1999.com/The_Gnome_Take`
- Local quest key: `kaladimb/Jeet`
- Local file: `server/internal/quest/overrides/lua/converted-perl/kaladimb/Jeet.lua`
- Status: reward pool updated; exact random odds approximate.

P99 lists eight possible reward items for the Gnome Take but does not give exact odds or distinguish different odds between the two local `Gnome Take` item variants.

Decision for now: use an even random choice from the eight P99-listed items for both local variants.

### The Gnoll Slayer later upgrade removal

- P99 page: `https://wiki.project1999.com/The_Gnoll_Slayer`
- Local quest key: `qeytoqrg/Marton_Sayer`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/qeytoqrg/Marton_Sayer.lua`
- Status: Classic Gnoll Slayer path preserved; later upgrade branch removed from the active override.

P99 explicitly notes that the second part of the Gnoll Slayer quest was added on live in Planes of Power and will not exist on Project 1999. Local upstream ProjectEQ Lua exposed that later `true potential` branch.

Decision for now: override Marton with only the Classic Baby Joseph Sayer turn-in, the base Gnoll Slayer reward, and P99 faction/coin directions.

### The New Worker charm/faction gate simplification

- P99 page: `https://wiki.project1999.com/The_New_Worker`
- Local quest key: `overthere/an_undead_foreman`
- Local file: `server/internal/quest/overrides/lua/converted-perl/overthere/an_undead_foreman.lua`
- Status: local turn-in remains direct/playable.

P99 documents the Worker Sledgemallet hand-in as requiring Amiable faction with Venril Sathir or use of charm/illusion tactics. Local IdleQuest quest Lua accepts the Jade hand-in directly and rewards the Worker Sledgemallet.

Decision for now: leave the direct hand-in. Charm-gated hostile NPC hand-ins are a broader combat/faction/runtime behavior and should be addressed consistently rather than per-script.

### The Rogue Take Freeport chest placement

- P99 page: `https://wiki.project1999.com/The_Rogue_Take`
- Local quest keys: `neriakc/Eolorn_J\`Axx`, `freeporteast/Giz_Dinree`, `freporte/Giz_Dinree`
- Local files: `server/internal/quest/overrides/lua/idlequest-authored/neriakc/Eolorn_J-slug-Axx.lua`, `server/migrations/098_add_p99_rogue_take_chest_ground_spawn.sql`
- Status: quest restored; revamp ground-spawn location needs in-game placement review.

P99 documents the old East Freeport locked chest at approximately `-406, -1150`. IdleQuest has both old `freporte` and newer `freeporteast` aliases. The migration adds the exact old-zone location for `freporte` and an approximate `freeporteast` placement near the local Giz Dinree harbor spawn.

Decision for now: keep the approximate `freeporteast` row so the quest is mechanically available, but review the chest location in the 3D client before calling the placement exact.

### The Orc Impaler Glidara spawn placement

- P99 page: `https://wiki.project1999.com/The_Orc_Impaler`
- Local quest keys: `kithicor/Morin_Shadowbane`, `lfaydark/Bryn_Fynndel`, `lfaydark/Glidara_Myllar`
- Local files: `server/internal/quest/overrides/lua/converted-perl/kithicor/Morin_Shadowbane.lua`, `server/internal/quest/overrides/lua/idlequest-authored/lfaydark/Bryn_Fynndel.lua`, `server/internal/quest/overrides/lua/idlequest-authored/lfaydark/Glidara_Myllar.lua`, `server/migrations/097_enable_p99_painting_and_orc_impaler.sql`
- Status: chain restored; spawn location derived from the existing local Glidara row.

P99 makes Glidara Myllar quest-spawned after Bryn receives the Shadowed Code Book. Local data previously had a static Glidara spawn group. The migration removes that static spawn, and Bryn now quest-spawns Glidara using the existing local Glidara coordinates.

Decision for now: use the existing local spawn coordinates rather than invent a new location. If player reports say she appears in the wrong part of Lesser Faydark, tune the spawn point separately.

### The Penance Bone Shatter proc runtime gap

- P99 page: `https://wiki.project1999.com/The_Penance`
- Local quest keys: `cabeast/The_Toilmaster`, Cabilis class guildmasters, `cabwest/a_mortician`
- Local files: `server/internal/quest/overrides/lua/converted-perl/cabeast/The_Toilmaster.lua`, `server/migrations/099_enable_p99_penance_combines.sql`
- Status: Lua and recipes are in place; the Hammer of Exoneration proc needs a runtime item-summon implementation.

P99 requires the Hammer of Exoneration to proc `Bone Shatter` repeatedly. That spell uses SPA 32, `SummonItem`, to create `Bone Fragment` item `24768`. Local item data has Hammer of Exoneration item `24767`, Bone Shatter spell `1333`, and Bone Fragment item `24768`, and migration `099` enables the Powdered Bone and Filled Penance Bag combines.

Current runtime evidence shows weapon procs are wired, but the client combat spell/proc effect handlers do not implement SPA 32 item summoning. That means the quest scripts and recipes can be correct while live players still cannot naturally generate Bone Fragments from the hammer proc.

Decision for now: document this as a quest-runtime gap. The correct fix should be a server-authorized summoned-item grant for SPA 32 procs, not a Lua shortcut, because inventory changes are server-owned.

### The Summoning of Fright missing Mundane Helm

- P99 page: `https://wiki.project1999.com/The_Summoning_of_Fright`
- Local quest key: `paineel/Sern_Adolia`
- Local file: `server/internal/quest/overrides/lua/converted-perl/paineel/Sern_Adolia.lua`
- Status: left playable through the existing direct reward path; exact P99 two-step avatar handoff is pending missing item data.

P99 documents Sern Adolia rewarding a `Mundane Helm`, spawning Avatar of Fright, and the avatar forging that intermediate item into `Fright Forged Helm`. IdleQuest has `Fright Forged Helm` item `14100`, but no local item row named `Mundane Helm` was found.

Decision for now: do not invent a Mundane Helm row. Keep the direct Sern reward path so the quest remains completable, and keep the missing item documented in `docs/quest-missing-items.md`.

### Unkempt Druids Jale Phlintoes branch

- P99 page: `https://wiki.project1999.com/Unkempt_Druids_(Quest)`
- Local quest key: `southkarana/a_hermit`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/southkarana/a_hermit.lua`
- Status: confirmed Winds of Karana sheet and cracked flute hand-ins remain enabled; speculative Jale Phlintoes spawn dialogue was removed.

P99 documents the Jale Phlintoes branch as unsolved/not implemented. Local ProjectEQ-derived behavior had a speculative `join the unkempt` style branch that could spawn Jale without a confirmed P99 solution.

Decision for now: keep only the confirmed Human Heart and Talym's Head hand-ins. Do not expose a likely-unsolved Jale branch until a confirmed classic/P99 path exists.

### Vasty Deep Water final reward variance

- P99 page: `https://wiki.project1999.com/Vasty_Deep_Water`
- Local quest key: `erudnext/Nolusia_Finharn`
- Local file: `server/internal/quest/upstream/projecteq/erudnext/Nolusia_Finharn.lua`
- Status: left unchanged pending stronger reward-table evidence.

P99's reward box lists `Erud's Tonic`, `Rusty Long Sword`, and `Splintering Club`, while the walkthrough transcript shows one observed final reward of `11 copper` and `Splintering Club`. Local Lua already uses a random reward from those three items and random small coin on the Label of Erud's Tonic hand-in.

Decision for now: treat the P99 page as evidence of a variable reward pool, not a deterministic `11 copper + Splintering Club` reward. Do not collapse local random rewards to one observed transcript unless stronger P99 evidence says the reward is fixed.

### Wall Squad Ring low-faction safety

- P99 page: `https://wiki.project1999.com/Wall_Squad_Ring`
- Local quest key: `rivervale/Hendi_Mrubble`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/rivervale/Hendi_Mrubble.lua`
- Status: charged/empty Squad Ring recharge added.

P99 says Hendi recharges the Squad Ring at indifferent or better and can eat the ring below that faction. IdleQuest generally avoids punitive item-eating traps where the user receives no useful feedback.

Decision for now: recharge the ring for acceptable faction and return the submitted ring with a refusal message at low faction instead of consuming it.

### Warrior Plane of Sky starter flow

- P99 page: `https://wiki.project1999.com/Warrior_Plane_of_Sky_Tests`
- Local quest keys: `airplane/Torgon_Blademaster`, `airplane/Falorn`, `airplane/Ogog`
- Local files changed: `server/internal/quest/overrides/lua/modified-upstream/airplane/Falorn.lua`, `server/internal/quest/overrides/lua/modified-upstream/airplane/Ogog.lua`
- Status: Falorn and Ogog hand-ins/rewards were corrected; Torgon still uses IdleQuest's existing direct-spawn tester pattern.

P99 documents Torgon giving a book/tome and then summoning the selected tester after the book is returned. Local Plane of Sky class starters commonly simplify this to direct tester spawning from dialogue.

Decision for now: keep the direct tester spawning and match the actual test hand-ins/rewards. The Warrior corrections in this batch add Falorn's Aerated Pauldrons -> Pauldrons of the Blue Sky upgrade and require all four P99 items for Ogog's Test of Think.

### Werewolf Skin Cloak EXP amount

- P99 page: `https://wiki.project1999.com/Werewolf_Skin_Cloak_Quest`
- Local quest key: `everfrost/Karg_IceBear`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/everfrost/Karg_IceBear.lua`
- Status: Werewolf Pelt + 100 platinum now gives Werewolf Skin Cloak and experience.

P99 explicitly says there are no faction hits but that the player does gain experience. The page does not identify the exact EXP amount.

Decision for now: add a modest quest EXP award so the mechanic matches P99's documented EXP reward. Revisit only if a confirmed P99 EXP value is found.

### Wizard Plane of Sky starter flow and Amulet upgrade

- P99 page: `https://wiki.project1999.com/Wizard_Plane_of_Sky_Tests`
- Local quest keys: `airplane/Wizard_Schrock`, `airplane/Neasin_Leornic`, `airplane/Abec_Ianor`
- Local file changed: `server/internal/quest/overrides/lua/modified-upstream/airplane/Abec_Ianor.lua`
- Status: Abec's test rewards now align with P99; starter flow remains simplified.

P99 documents Wizard Schrock giving a book and summoning Abec/Neasin after the book is returned. Local Plane of Sky class starters commonly simplify that to direct tester spawning from dialogue.

Decision for now: keep the existing direct tester-spawn model and align the actual tester hand-ins/rewards. Abec now rewards Amulet of the Void for Visualization and accepts the old Amulet of Planar Transference for upgrade to Amulet of the Void.

### Wolf Meat for Wista DNE page

- P99 page: `https://wiki.project1999.com/Wolf_Meat_for_Wista`
- Local quest key: none added
- Status: not implemented.

P99 marks this page `Delete`/`DNE` and notes that it was not working on Green as of the page text. Local data has no confirmed Wista Lua script.

Decision for now: do not invent Wista behavior or expose the quest. Revisit only if the P99 page is corrected with confirmed classic behavior.

### Xelha's Cyclops Eye classically broken branch

- P99 page: `https://wiki.project1999.com/Xelha%27s_Cyclops_Eye`
- Local quest keys: `freporte/Xelha_Nevagon`, `freeporteast/Xelha_Nevagon`
- Local files changed: `server/internal/quest/overrides/lua/modified-upstream/freporte/Xelha_Nevagon.lua`, `server/internal/quest/overrides/lua/modified-upstream/freeporteast/Xelha_Nevagon.lua`
- Status: earlier Xelha component hand-ins remain enabled; cyclops-eye completion reward is disabled.

P99 marks the cyclops-eye completion as classically broken and says Cyclops Eyes never drop on P99. IdleQuest's item/loot data currently has Cyclops Eye item `13927` and multiple cyclops drops, so leaving the old reward branch enabled would make an impossible P99 completion path actually work.

Decision for now: remove the reward branch for Cyclops Eye while keeping the earlier Assist the Great Xelha component turn-ins. If we later decide to fully simulate the broken P99 state, the better data-level fix would be auditing/removing Cyclops Eye drops from classic cyclops rows rather than rewarding Xelha's broken turn-in.

### Yegek's Test Part 1 small reward variance

- P99 pages: `https://wiki.project1999.com/Yegek%27s_Test,_Part_1`, `https://wiki.project1999.com/Yegek%27s_Test,_Part_2`
- Local quest key: `neriakb/Yegek_B-Larin`
- Local files changed: `server/internal/quest/overrides/lua/converted-perl/neriakb/Yegek_B-Larin.lua`, `server/migrations/103_enable_p99_final_batch_quest_data.sql`
- Status: both Yegek tests are implemented.

P99's Part 1 reward box lists small coin, Iron Ration, and Torch, while the walkthrough specifically observes 4 silver. The exact item odds are not documented.

Decision for now: give 4 silver and a random Iron Ration/Torch as the small reward. Migration 103 adds the missing Bag of Eyes n Bones combine and the TeirDal_coward head loot table required for Part 2.

### Zombie Flesh minor reward pool odds

- P99 page: `https://wiki.project1999.com/Zombie_Flesh_Quest`
- Local quest key: `erudnext/Dleria_Mausrel`
- Local files changed: `server/internal/quest/overrides/lua/modified-upstream/erudnext/Dleria_Mausrel.lua`, `server/migrations/103_enable_p99_final_batch_quest_data.sql`
- Status: final hand-in now gives coin, faction, EXP, and one P99-listed minor item.

P99 lists Backpack, Belt Pouch, Raw-hide Sleeves, Divine Aura, Flash of Light, Lull, and Spook the Dead as possible minor rewards but does not document exact odds.

Decision for now: use an even random pool across the listed rewards. Migration 103 enables the existing Bag Of Zombie Flesh combine.

### SoulFire non-paladin charge behavior

- P99 page: `https://wiki.project1999.com/Zimel%27s_Blades_(SoulFire)`
- Local quest key: `southkarana/#Brother_Hayle`
- Local file: `server/internal/quest/overrides/lua/modified-upstream/southkarana/#Brother_Hayle.lua`
- Status: SoulFire chain remains enabled; non-paladin zero-charge reward behavior is documented as a runtime/content gap.

P99 notes that non-paladins receive a zero-charge SoulFire. Local item `5504` has `maxcharges = 5`, and the Lua bridge's `SummonItem(item, secondArg)` currently treats the second argument as stack quantity, not item charge count.

Decision for now: do not fake charge behavior in Lua. The correct fix is a runtime/inventory capability for summoning items with explicit charges, then Brother Hayle can conditionally summon zero-charge SoulFire for non-paladins.

### P99 title-only candidate triage

- Tool: `npm run quests:triage-p99-title-candidates -- --details`
- Status: high-confidence P99 quest-category pages are fully represented in the audit ledger; title-only candidates are now triaged by script.

The title-only list contains many redirects, note/item pages, guides, and index pages. These are not independent quest implementation targets unless the triage tool reports them in `remainingManualReview`.

Specific decisions from this pass:

- `Cargo Clockwork (Quest)`: P99 says the quest was non-functioning in Classic and never functions on P99. `steamfont/Cargo_Clockwork` is explicitly excluded now, along with the already-excluded Jarah reward row.
- `Staff of Dark Reflections Quest`: P99 marks this unavailable/later-era and says Tilkzog Mournunder is not in game. `akanon/Tilkzog_Mournunder` is explicitly excluded.
- `Cap of the Arcane Order Quest`: P99 marks this LoY-era DNE. `qeynos/Juegile_Sohgohm` is explicitly excluded.
- `Fell Blade Quests`: P99 marks the armor/weapon quest page DNE. `paineel/Faratain` is explicitly excluded, but the separate Fell Blade starting guild-note hand-in remains enabled.
- `Templar of Fright Quests`: P99 marks this page DNE. `paineel/Sadorno_Chomosh` is explicitly excluded.
- `Mask of Draconic Enhancement (Quest)`: P99 marks it Unknown Era, notes it is commonly Velious/later, and says the giver is not currently in P99. `skyshrine/Iago_Sabuela` is explicitly excluded if present locally.
- `Pure Crystal Quest`: covered by the Paladin Epic audit and fixture through `kaladimb/Jark` and `kaladimb/Nella_Stonebraids`.
- `Poacher's Head Quest`: disambiguation page only; both Erudin and Surefall Glade target pages are audited separately.
- `Plane of Sky Quests (Old)`: historical reference for old Sky rewards made impossible by P99's 2011 Sky reward update; current class-specific Sky pages remain the implementation targets.
- `Kezzek's Fight Strategies for Rogue Epic Quest`: strategy/reference page only; Rogue Epic mechanics are covered by the main Rogue Epic audit and fixture.
