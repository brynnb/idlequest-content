CREATE TABLE `npc_spells_effects_entries` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `npc_spells_effects_id` int NOT NULL DEFAULT '0',
  `spell_effect_id` smallint NOT NULL DEFAULT '0',
  `minlevel` tinyint unsigned NOT NULL DEFAULT '0',
  `maxlevel` tinyint unsigned NOT NULL DEFAULT '255',
  `se_base` int NOT NULL DEFAULT '0',
  `se_limit` int NOT NULL DEFAULT '0',
  `se_max` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `spellsid_spellid` (`npc_spells_effects_id`,`spell_effect_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
