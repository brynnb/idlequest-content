CREATE TABLE `quests` (
  `id` int NOT NULL AUTO_INCREMENT,
  `zone` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `lua_content` mediumtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `has_say_event` tinyint(1) DEFAULT '0',
  `enabled` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_zone_name` (`zone`,`name`),
  KEY `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
