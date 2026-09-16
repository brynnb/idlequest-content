CREATE TABLE `npc_faction_entries` (
  `npc_faction_id` int unsigned NOT NULL DEFAULT '0',
  `faction_id` int unsigned NOT NULL DEFAULT '0',
  `value` int NOT NULL DEFAULT '0',
  `npc_value` tinyint NOT NULL DEFAULT '0',
  `temp` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`npc_faction_id`,`faction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
