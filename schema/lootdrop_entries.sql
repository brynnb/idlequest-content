CREATE TABLE `lootdrop_entries` (
  `lootdrop_id` int unsigned NOT NULL DEFAULT '0',
  `item_id` int NOT NULL DEFAULT '0',
  `item_charges` smallint unsigned NOT NULL DEFAULT '1',
  `equip_item` tinyint unsigned NOT NULL DEFAULT '0',
  `chance` float NOT NULL DEFAULT '1',
  `disabled_chance` float NOT NULL DEFAULT '0',
  `trivial_min_level` smallint unsigned NOT NULL DEFAULT '0',
  `trivial_max_level` smallint unsigned NOT NULL DEFAULT '0',
  `multiplier` tinyint unsigned NOT NULL DEFAULT '1',
  `npc_min_level` smallint unsigned NOT NULL DEFAULT '0',
  `npc_max_level` smallint unsigned NOT NULL DEFAULT '0',
  `min_expansion` tinyint NOT NULL DEFAULT '-1',
  `max_expansion` tinyint NOT NULL DEFAULT '-1',
  `content_flags` varchar(100) DEFAULT NULL,
  `content_flags_disabled` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`lootdrop_id`,`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
