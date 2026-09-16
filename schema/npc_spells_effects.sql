CREATE TABLE `npc_spells_effects` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` tinytext,
  `parent_list` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
