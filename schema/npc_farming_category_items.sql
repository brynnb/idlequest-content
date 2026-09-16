CREATE TABLE `npc_farming_category_items` (
  `npc_id` int NOT NULL,
  `category` varchar(32) NOT NULL,
  `item_id` int NOT NULL,
  `expected_drops_per_100` decimal(10,3) NOT NULL DEFAULT '0.000',
  PRIMARY KEY (`npc_id`,`category`,`item_id`),
  KEY `idx_farming_item_plan` (`category`,`item_id`,`npc_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
