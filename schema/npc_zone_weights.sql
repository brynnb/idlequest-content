CREATE TABLE `npc_zone_weights` (
  `id` int NOT NULL AUTO_INCREMENT,
  `zone_name` varchar(32) DEFAULT NULL,
  `npc_id` int DEFAULT NULL,
  `npc_name` varchar(64) DEFAULT NULL,
  `level` int DEFAULT NULL,
  `weight` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_zone_level` (`zone_name`,`level`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
