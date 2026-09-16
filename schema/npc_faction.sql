CREATE TABLE `npc_faction` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` tinytext,
  `primaryfaction` int NOT NULL DEFAULT '0',
  `ignore_primary_assist` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 PACK_KEYS=0;
