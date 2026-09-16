CREATE TABLE `faction_list` (
  `id` int NOT NULL,
  `name` varchar(50) NOT NULL DEFAULT '',
  `base` smallint NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;
