CREATE TABLE `pets_equipmentset` (
  `set_id` int NOT NULL,
  `setname` varchar(30) NOT NULL DEFAULT '',
  `nested_set` int NOT NULL DEFAULT '-1',
  PRIMARY KEY (`set_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
