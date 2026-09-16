CREATE TABLE `faction_base_data` (
  `client_faction_id` smallint NOT NULL,
  `min` smallint DEFAULT '-2000',
  `max` smallint DEFAULT '2000',
  `unk_hero1` smallint DEFAULT NULL,
  `unk_hero2` smallint DEFAULT NULL,
  `unk_hero3` smallint DEFAULT NULL,
  PRIMARY KEY (`client_faction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
