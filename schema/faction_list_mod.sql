CREATE TABLE `faction_list_mod` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `faction_id` int unsigned NOT NULL,
  `mod` smallint NOT NULL,
  `mod_name` varchar(16) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `faction_id_mod_name` (`faction_id`,`mod_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
