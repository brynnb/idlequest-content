CREATE TABLE `spawn_conditions` (
  `zone` varchar(32) NOT NULL DEFAULT '',
  `id` mediumint unsigned NOT NULL DEFAULT '1',
  `value` mediumint NOT NULL DEFAULT '0',
  `onchange` tinyint unsigned NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  PRIMARY KEY (`zone`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
