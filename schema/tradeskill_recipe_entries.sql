CREATE TABLE `tradeskill_recipe_entries` (
  `id` int NOT NULL AUTO_INCREMENT,
  `recipe_id` int NOT NULL DEFAULT '0',
  `item_id` int NOT NULL DEFAULT '0',
  `successcount` tinyint NOT NULL DEFAULT '0',
  `failcount` tinyint NOT NULL DEFAULT '0',
  `componentcount` tinyint NOT NULL DEFAULT '1',
  `salvagecount` tinyint NOT NULL DEFAULT '0',
  `iscontainer` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `recipe_id` (`recipe_id`) USING BTREE,
  KEY `item_id` (`item_id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
