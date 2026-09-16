CREATE TABLE `grid` (
  `id` int NOT NULL DEFAULT '0',
  `zoneid` int NOT NULL DEFAULT '0',
  `type` int NOT NULL DEFAULT '0',
  `type2` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`zoneid`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
