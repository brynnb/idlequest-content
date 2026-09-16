CREATE TABLE `npc_emotes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `emoteid` int unsigned NOT NULL DEFAULT '0',
  `event_` tinyint NOT NULL DEFAULT '0',
  `type` tinyint NOT NULL DEFAULT '0',
  `text` varchar(512) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
