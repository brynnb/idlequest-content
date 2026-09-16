CREATE TABLE `farming_category_items` (
  `category` varchar(32) NOT NULL,
  `item_id` int NOT NULL,
  PRIMARY KEY (`category`,`item_id`),
  KEY `idx_farming_category_item` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
