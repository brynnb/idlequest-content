CREATE TABLE `lootdrop` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `min_expansion` tinyint NOT NULL DEFAULT '-1',
  `max_expansion` tinyint NOT NULL DEFAULT '-1',
  `content_flags` varchar(100) DEFAULT NULL,
  `content_flags_disabled` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 PACK_KEYS=0;
