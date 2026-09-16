CREATE TABLE `loottable_entries` (
  `loottable_id` int unsigned NOT NULL DEFAULT '0',
  `lootdrop_id` int unsigned NOT NULL DEFAULT '0',
  `multiplier` tinyint unsigned NOT NULL DEFAULT '1',
  `droplimit` tinyint unsigned NOT NULL DEFAULT '0',
  `mindrop` tinyint unsigned NOT NULL DEFAULT '0',
  `probability` float NOT NULL DEFAULT '100',
  PRIMARY KEY (`loottable_id`,`lootdrop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
