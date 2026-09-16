CREATE TABLE `pets_equipmentset_entries` (
  `set_id` int NOT NULL,
  `slot` int NOT NULL,
  `item_id` int NOT NULL,
  PRIMARY KEY (`set_id`,`slot`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
