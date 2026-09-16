CREATE TABLE `spawn2_disabled` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `spawn2_id` int DEFAULT NULL,
  `instance_id` int DEFAULT '0',
  `disabled` smallint DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `spawn2_id` (`spawn2_id`,`instance_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
