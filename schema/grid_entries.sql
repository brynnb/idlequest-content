CREATE TABLE `grid_entries` (
  `gridid` int NOT NULL DEFAULT '0',
  `zoneid` int NOT NULL DEFAULT '0',
  `number` int NOT NULL DEFAULT '0',
  `x` float NOT NULL DEFAULT '0',
  `y` float NOT NULL DEFAULT '0',
  `z` float NOT NULL DEFAULT '0',
  `heading` float NOT NULL DEFAULT '0',
  `pause` int NOT NULL DEFAULT '0',
  `centerpoint` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`zoneid`,`gridid`,`number`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
