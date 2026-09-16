CREATE TABLE `spawnentry` (
  `spawngroupID` int NOT NULL DEFAULT '0',
  `npcID` int NOT NULL DEFAULT '0',
  `chance` smallint NOT NULL DEFAULT '0',
  `condition_value_filter` mediumint NOT NULL DEFAULT '1',
  `min_time` smallint NOT NULL DEFAULT '0',
  `max_time` smallint NOT NULL DEFAULT '0',
  `min_expansion` tinyint NOT NULL DEFAULT '-1',
  `max_expansion` tinyint NOT NULL DEFAULT '-1',
  `content_flags` varchar(100) DEFAULT NULL,
  `content_flags_disabled` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`spawngroupID`,`npcID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
