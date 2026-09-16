CREATE TABLE `crafting_merchant_items` (
  `item_id` int NOT NULL,
  `item_name` varchar(64) NOT NULL,
  `item_icon` int NOT NULL DEFAULT '0',
  `price` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`item_id`),
  KEY `idx_item_id` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
