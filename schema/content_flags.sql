CREATE TABLE `content_flags` (
  `id` int NOT NULL AUTO_INCREMENT,
  `flag_name` varchar(75) DEFAULT NULL,
  `enabled` tinyint DEFAULT NULL,
  `notes` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
