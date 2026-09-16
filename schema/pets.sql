CREATE TABLE `pets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `type` varchar(64) NOT NULL DEFAULT '',
  `petpower` int NOT NULL DEFAULT '0',
  `npcID` int NOT NULL DEFAULT '0',
  `temp` tinyint NOT NULL DEFAULT '0',
  `petcontrol` tinyint NOT NULL DEFAULT '0',
  `petnaming` tinyint NOT NULL DEFAULT '0',
  `monsterflag` tinyint NOT NULL DEFAULT '0',
  `equipmentset` int NOT NULL DEFAULT '-1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `type_petpower` (`type`,`petpower`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
