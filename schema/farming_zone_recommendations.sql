CREATE TABLE `farming_zone_recommendations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `category` varchar(32) NOT NULL,
  `spell_level_min` int DEFAULT NULL,
  `spell_level_max` int DEFAULT NULL,
  `zone_short_name` varchar(32) NOT NULL,
  `zone_long_name` varchar(128) NOT NULL,
  `mob_level_min` int NOT NULL,
  `mob_level_max` int NOT NULL,
  `spawn_points` int NOT NULL,
  `efficiency` enum('high','medium','low') NOT NULL DEFAULT 'medium',
  `description` text,
  `display_order` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_category` (`category`),
  KEY `idx_category_spell_level` (`category`,`spell_level_min`,`spell_level_max`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
