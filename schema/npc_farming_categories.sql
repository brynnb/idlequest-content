CREATE TABLE `npc_farming_categories` (
  `npc_id` int NOT NULL,
  `category` varchar(32) NOT NULL,
  PRIMARY KEY (`npc_id`,`category`),
  KEY `idx_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
