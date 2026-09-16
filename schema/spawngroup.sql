CREATE TABLE `spawngroup` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL DEFAULT '',
  `spawn_limit` tinyint NOT NULL DEFAULT '0',
  `dist` float NOT NULL DEFAULT '0',
  `max_x` float NOT NULL DEFAULT '0',
  `min_x` float NOT NULL DEFAULT '0',
  `max_y` float NOT NULL DEFAULT '0',
  `min_y` float NOT NULL DEFAULT '0',
  `delay` int NOT NULL DEFAULT '45000',
  `mindelay` int NOT NULL DEFAULT '15000',
  `despawn` tinyint NOT NULL DEFAULT '0',
  `despawn_timer` int NOT NULL DEFAULT '100',
  `wp_spawns` tinyint unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
