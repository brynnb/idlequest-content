CREATE TABLE `spawn_events` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `zone` varchar(32) DEFAULT NULL,
  `cond_id` mediumint unsigned NOT NULL DEFAULT '0',
  `name` varchar(255) NOT NULL DEFAULT '',
  `period` int unsigned NOT NULL DEFAULT '0',
  `next_minute` tinyint unsigned NOT NULL DEFAULT '0',
  `next_hour` tinyint unsigned NOT NULL DEFAULT '0',
  `next_day` tinyint unsigned NOT NULL DEFAULT '0',
  `next_month` tinyint unsigned NOT NULL DEFAULT '0',
  `next_year` int unsigned NOT NULL DEFAULT '0',
  `enabled` tinyint NOT NULL DEFAULT '1',
  `action` tinyint unsigned NOT NULL DEFAULT '0',
  `argument` mediumint NOT NULL DEFAULT '0',
  `strict` tinyint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
