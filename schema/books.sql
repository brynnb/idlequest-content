CREATE TABLE `books` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(30) NOT NULL DEFAULT '',
  `txtfile` text NOT NULL,
  `language` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `filename` (`name`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
