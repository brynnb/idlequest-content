# ProjectEQ Perl conversion backlog

Generated from current local DB/repo filters: runnable classic/Kunark `zone` rows (`version=0`, `peqzone=1`, `expansion in (0,1)`, not `min_expansion=99`), available item IDs from `items`, explicit Lua `-- name:` aliases, and local Lua overrides under `converted-perl`, `modified-upstream`, or `idlequest-authored`.

Runtime support note: movement, RandomRoam-style roaming capture, EVENT_CAST_ON, forced door-open capture, EVENT_PROXIMITY_SAY, and soulbinder bind capture are now recognized by the Lua runtime/audit. Classic/Kunark soulbinder scripts have been converted to Lua.

## Current status

- Reviewable item-bearing Perl scripts with all items available and no Lua: 0
- Item-bearing scripts excluded because all items exist but script is out-of-scope/plugin-only: 2
- Item-bearing scripts excluded because one or more referenced items are missing from IdleQuest DB: 159
- No-detected-item Perl scripts without local Lua: 141
- No-detected-item scripts classified as actionable by the audit: 0

## No-item disposition summary

- expansion-excluded: 59
- seasonal-event-excluded: 34
- task-system-excluded: 19
- skill-tome-plugin-excluded: 12
- ambience-event-excluded: 5
- gm-event-excluded: 5
- commented-out: 2
- removed-level-limit-excluded: 2
- empty: 1
- post-kunark-class-excluded: 1
- unavailable-zone-excluded: 1

## Reviewable no-item scripts

None. Remaining no-item Perl scripts are explicitly excluded by the audit.

## Item-bearing exclusions with all items available

- `cazicthule/48030.pl` (expansion-excluded) items: 8234
- `gfaydark/Tilania_Shadowwalker.pl` (skill-tome-plugin-excluded) items: 17365, 22671, 22672, 22673, 22674, 22675, 22676, 22677

## Missing-item exclusion examples

These scripts are not converted because they reference item IDs absent from the IdleQuest `items` table.

- `burningwood/Asmodin_Jru-dac.pl` missing: 62098, 62099, 62205
- `butcher/Vual_Stoutest.pl` missing: 40999, 41000
- `cabeast/Pagnar_Vyng.pl` missing: 65256
- `cauldron/Grimpl_Rustedcog.pl` missing: 67003, 67004, 67005
- `cauldron/Henai_Silentwalker.pl` missing: 41000
- `cazicthule/#Ikpug_Giblod.pl` missing: 57008
- `charasis/player.pl` missing: 62637
- `chardok/#Tani_Cogswin.pl` missing: 67054
- `commons/Bealya_Tanilsuia.pl` missing: 41000
- `eastkarana/Tholris.pl` missing: 62618, 62619, 62846
- `ecommons/Barstre_Songweaver.pl` missing: 40999, 41000
- `ecommons/Kayci_Strahtin.pl` missing: 55265, 55268, 55269
- `ecommons/Sergeant_Ragus.pl` missing: 84088, 84091, 84092, 84093
- `erudnext/#Jordin_Sretin.pl` missing: 55007
- `erudnext/#Senina_Jolik.pl` missing: 55004, 55028
- `erudnext/Alimaja_Shanthun.pl` missing: 61092, 61097, 63125
- `erudnext/Brianna_Falsruinay.pl` missing: 61001
- `erudnext/Kordian_Keshalian.pl` missing: 61093, 61098
- `erudnext/Valani_Gadriek.pl` missing: 65168
- `everfrost/Kizpi_Taelwx.pl` missing: 55268
- `everfrost/Teria_Grinntli.pl` missing: 40999, 41000
- `feerrott/#Emissary_Shinsere.pl` missing: 63105
- `feerrott/#druid_epic_trap.pl` missing: 62815
- `felwithea/Chenori_Berinal.pl` missing: 65212
- `fieldofbone/Immug_Lashtail.pl` missing: 84084, 84091, 84092, 84093
- `firiona/Gillia_Brissok.pl` missing: 62092, 62093, 62202
- `firiona/Rinnala_Sweetsong.pl` missing: 62072, 62073, 62192
- `firiona/Vorla_Diensk.pl` missing: 52009
- `firiona/Wekland_Greenfoot.pl` missing: 62082, 62083, 62197
- `freportw/Ginehl_Wiquar.pl` missing: 41000
- `frontiermtns/Cenobite_Pakclaw.pl` missing: 62088, 62089, 62200
- `frontiermtns/Digmaster_Duggert.pl` missing: 62100, 62101, 62206
- `frontiermtns/Rock_Shaper_Dritam.pl` missing: 62078, 62079, 62195
- `gfaydark/Faerik_Windrunner.pl` missing: 61004
- `gfaydark/Niflel_Faliwae.pl` missing: 40999, 41000
- `gfaydark/Seana_Marsinger.pl` missing: 54027, 54028, 54029, 54033, 54034, 54035, 54039, 54040, 54041, 54042, 54043, 54048, 54049, 54050, 54051, 54056, 54057, 54058, 54059, 54060, 54061, 54062
- `gfaydark/Stefan_Marsinger.pl` missing: 54030, 54031, 54032, 54036, 54037, 54038, 54039, 54044, 54045, 54046, 54047, 54052, 54053, 54054, 54055, 54056, 54057, 54058, 54059, 54060, 54061, 54062
- `grobb/Goldush.pl` missing: 51038, 55164, 55172, 55173, 55174, 55175, 55176, 55177, 55178, 55186
- `grobb/Grigdor.pl` missing: 51038, 55368, 55369, 55370, 55371, 55372, 55373, 55374, 55375, 55376
- `grobb/Kugaran.pl` missing: 61096, 61101
- `grobb/Prashnak.pl` missing: 61095, 61100
- `gukbottom/#a_spectral_shimmer.pl` missing: 67013
- `halas/Balgros_McMichael.pl` missing: 55118, 55126, 55134, 55135, 55136, 55137, 55138, 55139, 55140
- `halas/Conladan_Kevellian.pl` missing: 55148, 55156, 55157, 55158, 55159, 55160, 55161, 55162, 55163
- `halas/Haladorf_Wuirgon.pl` missing: 55344, 55345, 55346, 55347, 55348, 55349, 55350, 55352, 55353
- `halas/Rollian_Galothar.pl` missing: 55095, 55103, 55111, 55112, 55113, 55114, 55115, 55116, 55117
- `highpass/Shumpi_Wimahnn.pl` missing: 41000
- `hole/#Pellillo_Cogswin.pl` missing: 67053, 67054
- `innothule/#Sugal_the_Fist.pl` missing: 63090, 63091, 63098, 63099, 63103, 63104, 63105, 63106, 63107, 63108
- `innothule/Deblik_Grumblok.pl` missing: 41000
- ... 109 more in `scripts/quests/audit-perl-conversion-backlog.mjs --json <file>`

## No-item scripts by disposition

### expansion-excluded (58)
- `butcher/Rokaon_Sternheart.pl`
- `cabeast/player.pl`
- `cabwest/player.pl`
- `cauldron/#The_Fabled_Bilge_Farfathom.pl`
- `cauldron/#a_cauldron_rat.pl`
- `cauldron/#aqua_goblin_shaman.pl`
- `cauldron/an_aqua_goblin_mariner.pl`
- `cazicthule/#Avatar_of_Dread.pl`
- `cazicthule/#Avatar_of_Fright.pl`
- `cazicthule/#Avatar_of_Terror.pl`
- `cazicthule/#a_Tae_Ew_Justicar.pl`
- `cazicthule/#a_Thul_Tae_Ew_Tracker.pl`
- `cazicthule/#a_boiling_ooze.pl`
- `cazicthule/#a_bubbling_ooze.pl`
- `cazicthule/#a_swirling_ooze.pl`
- `cazicthule/#an_acidic_mass.pl`
- `cazicthule/#an_unstable_rift.pl`
- `cazicthule/48057.pl`
- `cazicthule/a_Thul_Tae_Ew_bloodcaller.pl`
- `cazicthule/a_Thul_Tae_Ew_defender.pl`
- `cazicthule/a_Thul_Tae_Ew_fanatic.pl`
- `cazicthule/a_Thul_Tae_Ew_judicator.pl`
- `cazicthule/a_Thul_Tae_Ew_justicar.pl`
- `cazicthule/a_Thul_Tae_Ew_protector.pl`
- `cazicthule/a_Thul_Tae_Ew_zealot.pl`
- `ecommons/Khaite_Ranna.pl`
- `feerrott/Grinak.pl`
- `fieldofbone/Vesh_Tailwhip.pl`
- `firiona/#Translocator_Drabilt.pl`
- `gukbottom/#a_corrupted_gnome_explorer.pl`
- `lakerathe/#Ronaiar_Skullmoore.pl`
- `lakerathe/#Worboli.pl`
- `misty/Roha_Jumthief.pl`
- `neriakb/player.pl`
- `neriakc/#Gribnor_the_Small.pl`
- `neriakc/player.pl`
- `nro/#Translocator_Ionie.pl`
- `oasis/#Translocator_Tradil.pl`
- `oggok/player.pl`
- `oot/#Translocator_Narrik.pl`
- `overthere/#Translocator_Breya.pl`
- `paineel/#Jerith.pl`
- `paineel/player.pl`
- `rathemtn/High_Seer_Flogk.pl`
- `rathemtn/Memory_of_Chalex.pl`
- `rathemtn/Troll_Captain_Krignok.pl`
- `rathemtn/Undead_Troll_Marauder.pl`
- `rathemtn/Warrior_Spirit_Chalex.pl`
- `rathemtn/player.pl`
- `shadowrest/A_Corpse_Harvester.pl`
- `shadowrest/Corpse_Caller.pl`
- `shadowrest/Keeper_of_Lost_Things.pl`
- `skyfire/#Dragon_Trigger.pl`
- `skyfire/91097.pl`
- `sro/Dible_Hedledrap.pl`
- `steamfont/Yama_Twerik.pl`
- `timorous/#Translocator_Deela.pl`
- `tox/Dovon_Traical.pl`

### seasonal-event-excluded (34)
- `kithicor/##Booberella.pl`
- `kithicor/##Captain_Scareyface.pl`
- `kithicor/##Casper.pl`
- `kithicor/##Count_Alucard.pl`
- `kithicor/##Eve_Hallows.pl`
- `kithicor/##Soldier_of_the_Damned.pl`
- `kithicor/##Solomon_Grundy.pl`
- `kithicor/##The_Great_Pumpkin.pl`
- `kithicor/##Tricksy_Treetor.pl`
- `kithicor/##a_Bat_with_Herpes.pl`
- `kithicor/##a_Ghost.pl`
- `kithicor/##a_Little_Demon.pl`
- `kithicor/##a_Spook.pl`
- `kithicor/##a_Vampire.pl`
- `kithicor/##a_Vampire_Bat.pl`
- `kithicor/##a_Werewolf_with_Rabies.pl`
- `kithicor/##a_Xombie.pl`
- `kithicor/##a_Zombie.pl`
- `kithicor/##an_Imp.pl`
- `kithicor/#a_jack_o_lantern.pl`
- `tox/a_pie_flinger.pl`
- `tox/a_pie_hurler.pl`
- `tox/a_pie_thrower.pl`
- `unrest/Casper.pl`
- `unrest/Evil_Brain_Eater.pl`
- `unrest/Eviler_Brain_Eater.pl`
- `unrest/Evilerer_Brain_Eater.pl`
- `unrest/Halloween_Trigger.pl`
- `unrest/Imp-ossible.pl`
- `unrest/Jack_o_Lantern.pl`
- `unrest/Not_So_Evil_Brain_Eater.pl`
- `unrest/Super_Ghoul_of_Unlimited_Power.pl`
- `unrest/Tiny_Jack.pl`
- `unrest/Werewolf_of_DOOOOOOOM.pl`

### task-system-excluded (19)
- `butcher/Alun_Bilgum.pl`
- `butcher/Atwin_Keladryn.pl`
- `butcher/Feriella_Vorana.pl`
- `butcher/Gibi_Bilgum.pl`
- `butcher/Savil_Tranquilsong.pl`
- `cauldron/Symperbell_Moor.pl`
- `ecommons/Loric_Weaver.pl`
- `ecommons/Merra_Clayfinger.pl`
- `freportw/Joffin_Sinclay.pl`
- `gfaydark/Guard_Orcflayer.pl`
- `kithicor/zombie_trooper.pl`
- `lavastorm/v1/Sidern_Delangan.pl`
- `lavastorm/v1/player.pl`
- `lfaydark/Averna_Eisley.pl`
- `misty/Bidils_the_Quickhand.pl`
- `nektulos/#checkpoint_ten.pl`
- `nektulos/player.pl`
- `rathemtn/Delila.pl`
- `steamfont/Brynn_Tinkerton.pl`

### skill-tome-plugin-excluded (12)
- `gfaydark/Sindl_Talonstrike.pl`
- `kaladimb/Dunony_Chestire.pl`
- `neriaka/#Gardunk.pl`
- `neriaka/Hukulk.pl`
- `neriaka/Ranjor.pl`
- `neriakb/Yegek_B-Larin.pl`
- `neriakc/Tralon_Din-a.pl`
- `oggok/Ruksa.pl`
- `qcat/Zaen_Kalystir.pl`
- `rathemtn/Bok_Master_Thragnog.pl`
- `rathemtn/Gaz_Master_Shargnol.pl`
- `rivervale/Hebber_Druneny.pl`

### gm-event-excluded (5)
- `steamfont/#Meldraths_Paige.pl`
- `steamfont/Minotaur_Hero.pl`
- `steamfont/Minotaur_Lord.pl`
- `steamfont/a_minotaur_slaver.pl`
- `steamfont/minotaur_slaver.pl`

### commented-out (2)
- `paineel/Kelkarn.pl`
- `paineel/Lolenton.pl`

### empty (1)
- `sro/#Gargantula.pl`
