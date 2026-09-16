CREATE TABLE `idlequest_enabled_ground_spawns` (
  `ground_spawn_id` int unsigned NOT NULL,
  `note` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`ground_spawn_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
