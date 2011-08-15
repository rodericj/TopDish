CREATE DATABASE `topdish`;
USE topdish;

CREATE TABLE `user` (
  `user_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fb_user_id` int(10) unsigned NOT NULL,
  `fb_access_token` varchar(512) CHARACTER SET latin1 DEFAULT NULL,
  `fb_access_token_expiry` int(10) unsigned DEFAULT NULL,
  `email` text,
  `email_hash` varchar(32) CHARACTER SET latin1 DEFAULT NULL,
  `email_access_token` varchar(32) CHARACTER SET latin1 DEFAULT NULL,
  `email_access_token_expiry` int(10) unsigned DEFAULT NULL,
  `salt` int(10) unsigned NOT NULL,
  `password_hash` varchar(32) CHARACTER SET latin1 DEFAULT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `type` tinyint(4) NOT NULL DEFAULT '0',
  `last_login` int(10) unsigned DEFAULT '0',
  `status` tinyint(4) NOT NULL DEFAULT '1',
  `roles` varchar(100) DEFAULT '',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `fb_user_id` (`fb_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `restaurant` (
  `restaurant_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  `address` text,
  `date_created` int(10) unsigned NOT NULL,
  `creator_id` int(10) unsigned NOT NULL,
  `num_positive_reviews` int(10) unsigned NOT NULL DEFAULT '0',
  `num_negative_reviews` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`restaurant_id`),
  KEY `creator_id` (`creator_id`),
  KEY `name` (`name`),
  CONSTRAINT `restaurant_ibfk_1` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `dish` (
  `dish_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` text,
  `date_created` int(10) unsigned NOT NULL,
  `creator_id` int(10) unsigned NOT NULL,
  `restaurant_id` int(10) unsigned NOT NULL,
  `num_positive_reviews` int(10) unsigned NOT NULL DEFAULT '0',
  `num_negative_reviews` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`dish_id`),
  KEY `restaurant_id` (`restaurant_id`),
  KEY `creator_id` (`creator_id`),
  KEY `name` (`name`),
  CONSTRAINT `dish_ibfk_1` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurant` (`restaurant_id`),
  CONSTRAINT `dish_ibfk_2` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_comment` (
  `comment_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `type` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '0 - restaurant, 1 - dish',
  `flag` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '0 - no flags',
  `obj_id` int(10) unsigned NOT NULL,
  `date_created` int(10) unsigned NOT NULL,
  `status` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `data` text NOT NULL,
  PRIMARY KEY (`comment_id`),
  UNIQUE KEY `user_id` (`user_id`,`obj_id`),
  CONSTRAINT `user_comment_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_follow` (
  `follow_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `type` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '0 - restaurant, 1 - dish',
  `obj_id` int(10) unsigned NOT NULL,
  `status` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`follow_id`),
  UNIQUE KEY `user_id` (`user_id`,`obj_id`),
  CONSTRAINT `user_follow_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_like` (
  `like_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `type` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '0 - restaurant, 1 - dish',
  `obj_id` int(10) unsigned NOT NULL,
  `status` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `flag_type` tinyint unsigned NOT NULL,
  PRIMARY KEY (`like_id`),
  UNIQUE KEY `user_id` (`user_id`,`obj_id`),
  CONSTRAINT `user_like_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_flag` (
  `flag_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(10) unsigned NOT NULL,
  `type` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '0 - restaurant, 1 - dish',
  `obj_id` int(10) unsigned NOT NULL,
  `status` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`flag_id`),
  UNIQUE KEY `user_id` (`user_id`,`obj_id`,`type`),
  CONSTRAINT `user_flag_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_photo` (
  `photo_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `creator_id` int(10) unsigned NOT NULL,
  `type` tinyint(3) unsigned NOT NULL DEFAULT '0' COMMENT '0 - restaurant, 1 - dish',
  `obj_id` int(10) unsigned NOT NULL,
  `date_created` int(10) unsigned NOT NULL,
  `status` tinyint(3) unsigned NOT NULL DEFAULT '0',
  `url` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`photo_id`),
  KEY `user_photo_ibfk_1` (`creator_id`),
  CONSTRAINT `user_userphoto_ibfk_1` FOREIGN KEY (`creator_id`) REFERENCES `user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `tag` (
  `tag_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `order` tinyint(3) unsigned DEFAULT '0',
  `type` varchar(30) NOT NULL,
  `name` varchar(30) NOT NULL,
  PRIMARY KEY (`tag_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `restaurant_tag` (
  `tag_id` int(10) unsigned NOT NULL,
  `restaurant_id` int(10) unsigned NOT NULL,
  `status` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`tag_id`, `restaurant_id`),
  CONSTRAINT `tag_ibfk_1` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`tag_id`),
  CONSTRAINT `restaurant_ibfk_2` FOREIGN KEY (`restaurant_id`) REFERENCES `restaurant` (`restaurant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `dish_tag` (
  `tag_id` int(10) unsigned NOT NULL,
  `dish_id` int(10) unsigned NOT NULL,
  `status` tinyint(3) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`tag_id`, `dish_id`),
  CONSTRAINT `tag_ibfk_2` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`tag_id`),
  CONSTRAINT `dish_tag_ibfk_1` FOREIGN KEY (`dish_id`) REFERENCES `dish` (`dish_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT IGNORE INTO tag (tag_id, `order`, type, name) VALUES (1518057, 0, "Cuisine", "Scandinavian"),(89004, 0, "Cuisine", "Chinese"),(82003, 4, "Lifestyle", "Gluten Free"),(219003, 8, "Meal Type", "Drink"),(913006, 0, "Cuisine", "Korean"),(1520054, 0, "Cuisine", "Russian"),(113001, 0, "Cuisine", "Afghani"),(1300014, 0, "Cuisine", "Asian Fusion"),(917007, 0, "Cuisine", "Thai"),(232003, 5, "Meal Type", "Entree"),(81003, 0, "Allergen", "Fish"),(92002, 0, "Cuisine", "Mexican"),(120001, 0, "Allergen", "Tree Nuts"),(117001, 2, "Lifestyle", "Vegan"),(195002, 4, "Meal Type", "Starter"),(119001, 0, "Allergen", "Shellfish"),(56001, 1, "Price", "$5-$10"),(105002, 0, "Cuisine", "Mediterranean"),(1350035, 0, "Cuisine", "Moroccan"),(219002, 3, "Meal Type", "Salad"),(1348037, 0, "Cuisine", "Austrian"),(1407010, 0, "Cuisine", "Creole"),(983004, 0, "Cuisine", "Middle Eastern"),(115001, 0, "Cuisine", "Greek"),(217002, 0, "Meal Type", "Breakfast"),(116001, 0, "Cuisine", "Brazilian"),(57001, 3, "Price", "$16-$20"),(122001, 0, "Allergen", "Soy"),(1442010, 0, "Cuisine", "Belgian"),(1443018, 0, "Cuisine", "Steakhouses"),(56002, 2, "Price", "$11-$15"),(1456010, 0, "Cuisine", "Cuban"),(239001, 2, "Meal Type", "Soup"),(240001, 7, "Meal Type", "Dessert"),(1300016, 0, "Cuisine", "Argentine"),(1441107, 0, "Cuisine", "Filipino"),(1450012, 0, "Cuisine", "Soul Food"),(1064001, 0, "Cuisine", "Iranian"),(238001, 4, "Price", "$20+"),(987004, 6, "Meal Type", "Side"),(58001, 0, "Cuisine", "Japanese"),(944010, 0, "Cuisine", "Caribbean"),(1521034, 0, "Cuisine", "Singaporean"),(99004, 0, "Cuisine", "Latin American"),(1349034, 0, "Cuisine", "American (Traditional)"),(83002, 0, "Cuisine", "Spanish"),(112002, 0, "Allergen", "Milk"),(1350037, 0, "Cuisine", "Burmese"),(1053002, 0, "Cuisine", "Persian"),(118001, 5, "Lifestyle", "Raw"),(743003, 6, "Lifestyle", "No Dairy"),(93002, 1, "Lifestyle", "Pescetarian"),(1620045, 0, "Cuisine", "Ethiopian"),(52001, 0, "Cuisine", "Italian"),(81002, 0, "Allergen", "Wheat"),(114001, 0, "Cuisine", "French"),(1443020, 0, "Cuisine", "Taiwanese"),(1088001, 0, "Cuisine", "Turkish"),(99003, 0, "Cuisine", "Indian"),(1199008, 0, "Cuisine", "Vietnamese"),(231002, 1, "Meal Type", "Sandwich"),(1520025, 0, "Cuisine", "Malaysian"),(1163003, 0, "Lifestyle", "No Pork"),(53001, 0, "Cuisine", "Seafood"),(55001, 0, "Price", "Less than $5"),(1241004, 0, "Cuisine", "American (New)"),(910004, 0, "Lifestyle", "Halal"),(1449005, 0, "Cuisine", "Portuguese"),(108002, 0, "Lifestyle", "Vegetarian"),(818001, 7, "Lifestyle", "Paleo Diet"),(98002, 0, "Allergen", "Peanuts"),(1186003, 0, "Cuisine", "Peruvian"),(121001, 0, "Allergen", "Egg");
